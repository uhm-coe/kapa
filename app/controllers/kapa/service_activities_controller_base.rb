module Kapa::ServiceActivitiesControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @service_activities = Kapa::ServiceActivity.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def new
    @person = Kapa::Person.find(params[:id])
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @service_activity = Kapa::ServiceActivity.new(service_activity_params)
    @service_activity.attributes = service_activity_params
    @service_activity.person = @person

    unless @service_activity.save
      flash[:danger] = error_message_for(@service_activity)
      redirect_to new_kapa_service_activity_path(:id => @person) and return false
    end

    flash[:success] = "Service activity was successfully created."
    redirect_to kapa_service_activity_path(:id => @service_activity)
  end

  def show
    @service_activity = Kapa::ServiceActivity.find(params[:id])
    @person = @service_activity.person
  end

  def update
    @service_activity = Kapa::ServiceActivity.find(params[:id])
    @service_activity.attributes = service_activity_params

    unless @service_activity.save
      flash[:danger] = @service_activity.errors.full_messages.join(", ")
      redirect_to kapa_service_activity_path(:id => @service_activity) and return false
    end

    flash[:success] = "Service activity was successfully updated."
    redirect_to kapa_service_activity_path(:id => @service_activity)
  end

  def destroy
    @service_activity = Kapa::ServiceActivity.find(params[:id])
    unless @service_activity.destroy
      flash[:danger] = error_message_for(@service_activity)
      redirect_to kapa_service_activity_path(:id => @service_activity) and return false
    end
    flash[:success] = "Service activity was successfully deleted."
    redirect_to kapa_person_path(:id => @service_activity.person_id)
  end

  private
  def service_activity_params
    params.require(:service_activity).permit(:person_id, :dept, :yml, :xml, :service_type, :affiliation, :role, :name, :compensation, :relevant, :context, :description, :award_id, :public, :image)
  end
end