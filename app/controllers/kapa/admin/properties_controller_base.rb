module Kapa::Admin::PropertiesControllerBase
  extend ActiveSupport::Concern

  included do
    before_filter :check_manage_permission
  end

  def show
    @property = Kapa::ApplicationProperty.find params[:id]
  end

  def new
    @filter = filter
    @property = Kapa::ApplicationProperty.new
    @property.name = @filter.property_name
  end

  def update
    @property = Kapa::ApplicationProperty.find params[:id]
    @property.attributes= params[:property]

    if @property.save
      flash[:success] = "System property was successfully updated."
    else
      flash[:danger] = error_message_for(@property)
    end
    redirect_to kapa_admin_property_path(:id => @property)
  end

  def create
    @property = Kapa::ApplicationProperty.new
    @property.attributes= params[:property]

    unless @property.save
      flash[:danger] = error_message_for(@property)
      redirect_to new_kapa_admin_property_path and return false
    end
    flash[:success] = 'System property was successfully created.'
    redirect_to kapa_admin_property_path(:id => @property, :focus => params[:focus])
  end

  def index
    @filter = filter
    @properties = Kapa::ApplicationProperty.search(@filter).order("sequence DESC, code").paginate(:page => params[:page], :per_page => @filter.per_page)
  end
end
