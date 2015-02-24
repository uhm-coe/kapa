class Kapa::Admin::PropertiesController < Kapa::Admin::BaseController
  before_filter :check_manage_permission

  def show
    @property = ApplicationProperty.find params[:id]
  end

  def new
    @filter = filter
    @property = ApplicationProperty.new
    @property.name = @filter.property_name
  end

  def update
    @property = ApplicationProperty.find params[:id]
    @property.attributes= params[:property]

    if @property.save
      flash[:success] = "System property was successfully updated."
    else
      flash[:danger] = error_message_for(@property)
    end
    redirect_to kapa_admin_property_path(:id => @property)
  end

  def create
    @property = ApplicationProperty.new
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
    @per_page_selected = @filter.per_page || Rails.configuration.items_per_page
    @properties = ApplicationProperty.search(@filter).order("sequence DESC, code").paginate(:page => params[:page], :per_page => @per_page_selected)
  end
end
