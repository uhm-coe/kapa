module Kapa::UsersControllerBase
  extend ActiveSupport::Concern

  def show
    @user = Kapa::User.find params[:id]
    @user_ext = @user.ext
    @permission = @user.deserialize(:permission, :as => OpenStruct)
    params[:anchor] = "activity" if params[:page].present?
    @timestamps = @user.user_timestamps.eager_load(:user => :person).limit(200).order("timestamps.id desc").paginate(:page => params[:page], :per_page => Rails.configuration.items_per_page)
    @users = @user.person.users
    @person = @user.person
  end

  def new
    @person = Kapa::Person.new
    @user = @person.users.build
  end

  def update
    @user = Kapa::User.find params[:id]
    @user.attributes = user_params if params[:user]
    @user.update_serialized_attributes!(:_ext, params[:user_ext]) if params[:user_ext].present?
    @user.serialize(:permission, params[:permission]) if params[:permission]
    @user.apply_role(params[:role][:role]) if params[:role]
    if @user.save
      flash[:success] = "User was successfully updated."
    else
      flash[:danger] = error_message_for(@user)
    end
    redirect_to kapa_user_path(:id => @user, :anchor => params[:anchor])
  end

  def create
    @person = Kapa::Person.new(person_params)
    case params[:mode]
    when "promote"
      @person_verified = Kapa::Person.lookup(params[:person][:id_number])
      @person_verified.merge(@person)
      @person = @person_verified
      flash[:success] = "Person was successfully imported."

    when "consolidate"
      @person_verified = Kapa::Person.lookup(params[:person][:id_number])
      @person_verified.merge(@person)
      @person = @person_verified
      flash[:success] = "Records were successfully consolidated."
    else
      flash[:success] = "Person was successfully created."
    end

    unless @person.save
      flash[:success] = nil
      flash[:danger] = "Failed to save this record."
      redirect_to new_kapa_user_path and return false
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
      redirect_to new_kapa_user_path and return false
    end

    flash[:success] = 'User was successfully created.'
    redirect_to :action => :show, :id => @user
  end

  def index
    @filter = filter
    @users = Kapa::User.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def import
    # TODO: Fix corresponding view
    errors = 0
    file = params[:data][:import_file]
    CSV.foreach(file.path, :headers => true) do |row|
      user = Kapa::User.find_by_uid(row["uid"])
      user = Kapa::User.new(:uid => row["uid"], :status => 0) if user.blank?
      user.status = row["status"]
      user.category = row["category"]
      user.position = row["position"]
      user.primary_dept = row["primary_dept"]

      person = user.person
      person = Kapa::Person.find_by_id_number(row["id_number"]) if person.blank?
      person = user.build_person(:id_number => row["id_number"]) if person.blank?
      person.last_name = row["last_name"]
      person.first_name = row["first_name"]
      person.status = row["status"]
      unless person.save
        errors = errors + 1
        logger.error "!!!!-- Failed to save person: {#{person.errors.full_messages}}"
      end

      user.person = person
      unless user.save
        errors = errors + 1
        logger.error "!!!!-- Failed to save user: {#{user.errors.full_messages}}"
      end
    end
    flash[:info] = "Users were imported. Errors: #{errors}"
    redirect_to kapa_users_path
  end

  def export
    @filter = filter
    send_data Kapa::User.to_csv(:filter => @filter),
              :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "user_#{Date.today}.csv"
  end

  def user_params
    params.require(:user).permit(:uid, :password, :category, :status, :primary_dept, :position, :person_id, :dept=>[])
  end

  def person_params
    params.require(:person).permit(:id_number, :last_name, :middle_initial, :birth_date, :ssn, :ssn_agreement,
                                   :email, :first_name, :other_name, :title, :gender, :status)
  end

end
