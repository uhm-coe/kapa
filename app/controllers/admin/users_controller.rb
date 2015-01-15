class Admin::UsersController < Admin::BaseController
  before_filter :check_manage_permission

  def show
    @user = User.find params[:id]
    @role = @user.deserialize(:role, :as => OpenStruct)
    @timestamps = @user.user_timestamps.find(:all, :include => {:user => :person}, :limit => 200, :order => "id desc")
    @users = @user.person.users
    @person = @user.person
    # TODO: Uncomment it later (temporarily commented out so admin/users/show won't throw an "undefined local variable or method 'config'" error)
    #@acknowledgements = @user.acknowledgements
    @person.details(self)
  end

  def new
    @person = Person.new
    @user = @person.users.build
  end

  def update
    @user = User.find params[:id]
    @user.attributes= params[:user]
    @user.serialize(:role, params[:role]) if params[:role]
    if @user.save
      flash[:success] = "User was successfully updated."
    else
      flash[:danger] = error_message_for(@user)
    end
    redirect_to admin_user_path(:id => @user)
  end

  def create
    @person = Person.new(params[:person])
    case params[:mode]
    when "promote"
      @person_verified = Person.search(:first, params[:person][:id_number], :verified => true)
      @person_verified.merge(@person)
      @person = @person_verified
      flash[:success] = "Person was successfully imported."

    when "consolidate"
      @person_verified = Person.search(:first, params[:person][:id_number], :verified => true)
      @person_verified.merge(@person)
      @person = @person_verified
      flash[:success] = "Records were successfully consolidated."
    else
      flash[:success] = "Person was successfully created."
    end

    unless @person.save
      flash[:success] = nil
      flash[:danger] = "Failed to save this record."
      redirect_to new_admin_user_path and return false
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
      redirect_to new_admin_user_path and return false
    end

    flash[:success] = 'User was successfully created.'
    redirect_to :action => :show, :id => @user
  end

  def index
    @filter = users_filter
    @users = User.paginate(:page => params[:page], :per_page => 20, :include => :person, :conditions => @filter.conditions, :order => "users.uid")
  end

  def logs
    @filter = timestamps_filter
    @timestamps = UserTimestamp.find(:all, :include => :user, :order => "timestamps.id DESC", :conditions => @filter.conditions)
  end

  def import
    file = params[:import_file]
    CSV.new(file, :headers => true).each do |row|
      person = Person.search(:first, row[0], :verified => true)

      if person
        if person.email.blank?
          p = Person.find_by_ldap(:first, person.id_number)
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
            logger.error "---Failed to save user: {#{user.errors.full_messages}}--"
          end
        end
      end
    end
    flash[:info] = "#{@persons.length} found."
  end

  def export
    @filter = users_filter
    @users = User.find(:all, :include => :person, :conditions => @filter.conditions, :order => "users.uid")
    csv_string = CSV.generate do |csv|
      csv << table_format.keys
      @users.each {|c| csv << table_format(c).values}
    end
    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "user_#{Date.today}.csv"
  end

  private
  def table_format(o = nil)
    row = {
      :uid => rsend(o, :uid),
      :id_number => rsend(o, :person, :id_number),
      :last_name => rsend(o, :person, :last_name),
      :first_name => rsend(o, :person, :first_name),
      :position => rsend(o, :position),
      :department => rsend(o, :department),
      :emp_status => rsend(o, :emp_status),
      :status => rsend(o, :status),
      :role_main => rsend(o, :role, :main),
      :role_artifact => rsend(o, :role, :artifact),
      :role_advising => rsend(o, :role, :advising),
      :role_curriculum => rsend(o, :role, :curriculum),
      :role_assessment => rsend(o, :role, :course),
      :role_practicum => rsend(o, :role, :practicum),
      :dept => rsend(o, :dept),
      :category => rsend(o, :category)
    }
    row
  end

  def users_filter
    f = filter
    f.append_condition "department = ?", :department
    f.append_condition "users.status = ?", :status
    f.append_condition "emp_status = ?", :emp_status
    f.append_condition "users.uid like ? or persons.last_name like ? or persons.first_name like ?", :key, :like => true
    return f
  end

  def timestamps_filter
    f = filter
    f.append_condition "date(convert_tz(created_at, '+00:00', '-10:00')) >= ?", :date_start
    f.append_condition "date(convert_tz(created_at, '+00:00', '-10:00')) <= ?", :date_end
    f.append_condition "path like ?", :path, :like => true
    return f
  end

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
