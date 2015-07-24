module Kapa::Admin::UsersControllerBase
  extend ActiveSupport::Concern

  included do
    before_filter :check_manage_permission
  end

  def show
    @user = Kapa::User.find params[:id]
    @permission = @user.deserialize(:permission, :as => OpenStruct)
    params[:focus] = "activity" if params[:page].present?
    @timestamps = @user.user_timestamps.eager_load(:user => :person).limit(200).order("timestamps.id desc").paginate(:page => params[:page], :per_page => Rails.configuration.items_per_page)
    @users = @user.person.users
    @person = @user.person
    @person.details(self)
  end

  def new
    @person = Kapa::Person.new
    @user = @person.users.build
  end

  def update
    @user = Kapa::User.find params[:id]
    @user.attributes = params[:user] if params[:user]
    @user.serialize(:permission, params[:permission]) if params[:permission]
    if @user.save
      flash[:success] = "User was successfully updated."
    else
      flash[:danger] = error_message_for(@user)
    end
    redirect_to kapa_admin_user_path(:id => @user, :focus => params[:focus])
  end

  def create
    @person = Kapa::Person.new(params[:person])
    case params[:mode]
    when "promote"
      @person_verified = Kapa::Person.lookup(params[:person][:id_number], :verified => true)
      @person_verified.merge(@person)
      @person = @person_verified
      flash[:success] = "Person was successfully imported."

    when "consolidate"
      @person_verified = Kapa::Person.lookup(params[:person][:id_number], :verified => true)
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
    @users = Kapa::User.search(@filter).order("users.uid").paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def logs
    @filter = filter
    @timestamps = Kapa::UserTimestamp.search(@filter).order("timestamps.id DESC")
  end

  def import
    errors = 0
    file = params[:import_file]
    CSV.foreach(file, :headers => true) do |row|
      user = Kapa::User.find_by_uid(row["uid"])
      user = Kapa::User.build(:uid => row["uid"], :status => 0) if user.blank?
      user.status = row["status"]
      user.category = row["category"]
      user.position = row["position"]
      user.emp_status = 2
      user.department = row["department"]
      unless user.save
        errors = errors + 1
        logger.error "!!!!-- Failed to save user: {#{user.errors.full_messages}}"
      end
      person = user.person
      person = user.build_person(:id_number => row["id_number"]) if person.blank?
      person.last_name = row["last_name"]
      person.first_name = row["first_name"]
      perdson.status = row["status"]
      unless person.save
        errors = errors + 1
        logger.error "!!!!-- Failed to save person: {#{person.errors.full_messages}}"
      end
    end
    flash[:info] = "Users were imported. Errors: #{errors}"
  end

  def export
    @filter = filter
    logger.debug "----filter: #{@filter.inspect}"
    send_data Kapa::User.to_csv(@filter),
              :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "user_#{Date.today}.csv"
  end
end