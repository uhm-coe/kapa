module Kapa::ServiceActivitiesControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @service_activities = Kapa::ServiceActivity.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end
end