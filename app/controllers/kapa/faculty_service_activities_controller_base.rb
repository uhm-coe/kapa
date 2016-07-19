module Kapa::FacultyServiceActivitiesControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @service_activities = Kapa::FacultyServiceActivity.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def new
    @person = Kapa::Person.find(params[:id])
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @service_activity = Kapa::FacultyServiceActivity.new(service_activity_params)
    @service_activity.attributes = service_activity_params
    @service_activity.person = @person

    unless @service_activity.save
      flash[:danger] = error_message_for(@service_activity)
      redirect_to new_kapa_faculty_service_activity_path(:id => @person) and return false
    end

    flash[:success] = "Service activity was successfully created."
    redirect_to kapa_faculty_service_activity_path(:id => @service_activity)
  end

  def show
    @service_activity = Kapa::FacultyServiceActivity.find(params[:id])
    @service_activity_ext = @service_activity.ext
    @person = @service_activity.person
  end

  def update
    @service_activity = Kapa::FacultyServiceActivity.find(params[:id])
    @service_activity.attributes = service_activity_params
    @service_activity.update_serialized_attributes!(:_ext, params[:service_activity_ext]) if params[:service_activity_ext].present?

    unless @service_activity.save
      flash[:danger] = @service_activity.errors.full_messages.join(", ")
      redirect_to kapa_faculty_service_activity_path(:id => @service_activity) and return false
    end

    flash[:success] = "Service activity was successfully updated."
    redirect_to kapa_faculty_service_activity_path(:id => @service_activity)
  end

  def destroy
    @service_activity = Kapa::FacultyServiceActivity.find(params[:id])
    unless @service_activity.destroy
      flash[:danger] = error_message_for(@service_activity)
      redirect_to kapa_faculty_service_activity_path(:id => @service_activity) and return false
    end
    flash[:success] = "Service activity was successfully deleted."
    redirect_to kapa_person_path(:id => @service_activity.person_id)
  end

  def export
    @filter = filter
    send_data Kapa::FacultyServiceActivity.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "faculty_service_activities_#{@filter.date_start.to_s}.csv"
  end

  private
  def service_activity_params
    params.require(:service_activity).permit(:person_id, :dept, :yml, :xml, :service_type, :service_date_start, :service_date_end, :affiliation, :role, :name, :compensation, :relevant, :context, :description, :public, :image, :faculty_award_ids => [])
  end
end