class Admin::PropertiesController < Admin::BaseController
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

    unless @property.save
      flash.now[:notice1] = error_message_for(@property)
      render_notice and return false
    end
    flash[:notice1] = "System property was successfully updated."
    render_notice
  end

  def create
    @property = ApplicationProperty.new
    @property.attributes= params[:property]
    unless @property.save
      flash.now[:notice1] = error_message_for(@property)
      render_notice and return false
    end
    flash[:notice1] = 'System property was successfully created..'
    redirect_to :action => :show, :id => @property, :focus => params[:focus]
  end

  def index
    @filter = filter
    @filter.append_condition "name = ?", :name
    @filter.append_condition "active = ?", :active
    @properties = ApplicationProperty.find(:all, :order => "sequence DESC, code", :conditions => @filter.conditions)
  end
end
