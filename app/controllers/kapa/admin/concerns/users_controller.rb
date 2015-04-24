module Kapa::Admin::Concerns::UsersController
  extend ActiveSupport::Concern

  included do
    before_filter :check_manage_permission
  end

  def show
    @user = User.find params[:id]
    @role = @user.deserialize(:role, :as => OpenStruct)
    params[:focus] = "activity" if params[:page].present?
    @timestamps = @user.user_timestamps.includes(:user => :person).limit(200).order("id desc").paginate(:page => params[:page], :per_page => Rails.configuration.items_per_page)
    @users = @user.person.users
    @person = @user.person
    @person.details(self)
  end

  def new
    @person = Person.new
    @user = @person.users.build
  end

  def update
    @user = User.find params[:id]
    @user.attributes = params[:user]
    @user.serialize(:role, params[:role]) if params[:role]
    if @user.save
      flash[:success] = "User was successfully updated."
    else
      flash[:danger] = error_message_for(@user)
    end
    redirect_to kapa_admin_user_path(:id => @user, :focus => params[:focus])
  end

  def create
    @person = Person.new(params[:person])
    case params[:mode]
    when "promote"
      @person_verified = Person.lookup(params[:person][:id_number], :verified => true)
      @person_verified.merge(@person)
      @person = @person_verified
      flash[:success] = "Person was successfully imported."

    when "consolidate"
      @person_verified = Person.lookup(params[:person][:id_number], :verified => true)
      @person_verified.merge(@person)
      @person = @person_verified
      flash[:success] = "Records were successfully consolidated."
    else
      flash[:success] = "Person was successfully created."
    end

    unless @person.save
      flash[:success] = nil
      flash[:danger] = "Failed to save this record."
      redirect_to new_kapa_admin_user_path and return false
    end

    if not @person.email.blank?
      uid = @person.email.split("@").first
    elsif not @person.id_number.blank?
      uid = @person.id_number
    else
      uid = @person.id
    end

    @user = @person.users.create(:uid => uid)
    unless @user.save
      flash[:success] = nil
      flash[:danger] = error_message_for(@user)
      redirect_to new_kapa_admin_user_path and return false
    end

    flash[:success] = 'User was successfully created.'
    redirect_to :action => :show, :id => @user
  end

  def index
    @filter = filter
    @users = User.search(@filter).order("users.uid").paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def logs
    @filter = filter
    @timestamps = UserTimestamp.search(@filter).order("timestamps.id DESC")
  end

  def import
    file = params[:import_file]
    CSV.new(file, :headers => true).each do |row|
      person = Person.lookup(row[0], :verified => true)

      if person
        if person.email.blank?
          p = DirectoryService.person(person.id_number)
          person.email = p.email if p and p.email.present?
        end

        person.save
        if person.email.present?
          uid = person.email.split("@").first
          user = User.find_by_uid(uid)
          user = User.build(:uid => uid, :status => 0, :category => "ldap", :person_id => @person.id) if user.nil?
          user.position = row["position"]
          user.department = [department(row["eac1"]), department(row["eac2"]), department(row["eac3"]), department(row["eac4"])].delete_if {|e| e.nil?}.first
          user.emp_status = 2
          unless user.save
            logger.error "!!!!-- Failed to save user: {#{user.errors.full_messages}}"
          end
        end
      end
    end
    flash[:info] = "#{@persons.length} found."
  end

  def export
    @filter = filter
    logger.debug "----filter: #{@filter.inspect}"
    send_data User.to_csv(@filter),
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "user_#{Date.today}.csv"
  end

  private
  def department(eac)
    if eac.blank?
      return nil
    else
      case(eac.to_s[4..5])
        when "01" then "DO"
        when "11" then "ITE"
        when "12" then "EDEA"
        when "13" then "EDEP"
        when "14" then "KRS"
        when "15" then "EDEF"
        when "16" then "EDTC"
        when "17" then "SPED"
        when "18" then "EDCS"
        when "19" then "TDP"
        when "31" then "CRDG"
        when "41" then "CDS"
        when "51" then "OSAS"
        else nil
      end
    end
  end
end
