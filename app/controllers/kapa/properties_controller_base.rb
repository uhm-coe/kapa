module Kapa::PropertiesControllerBase
  extend ActiveSupport::Concern

  def show
    @property = Kapa::Property.find params[:id]
    @property_ext = @property.ext
    @property_names = Kapa::Property.select("distinct name").where("length(name) > 0").order('1').collect { |p| p.name }
  end

  def new
    @filter = filter
    @property = Kapa::Property.new
    @property.name = @filter.property_name
    @property_names = Kapa::Property.select("distinct name").where("length(name) > 0").order('1').collect { |p| p.name }
  end

  def update
    @property = Kapa::Property.find params[:id]
    @property.attributes= property_params
    @property.update_serialized_attributes!(:_ext, params[:property_ext]) if params[:property_ext].present?

    if @property.save
      flash[:notice] = "System property was successfully updated."
    else
      flash[:alert] = error_message_for(@property)
    end
    redirect_to kapa_property_path(:id => @property)
  end

  def create
    @property = Kapa::Property.new
    @property.attributes= property_params

    unless @property.save
      flash[:alert] = error_message_for(@property)
      redirect_to new_kapa_property_path and return false
    end
    flash[:notice] = 'System property was successfully created.'
    redirect_to kapa_property_path(:id => @property, :anchor => params[:anchor])
  end

  def index
    @filter = filter
    @modal = true if @filter.name.blank?
    @properties = Kapa::Property.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end


  def export
    @filter = filter
    send_data Kapa::Property.to_table(:as => :csv, :filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "properties.csv"
  end

  private
  def property_params
    params.require(:property).permit(:name, :code, :description, :description_short, :category, :sequence, :active, :dept, :depts => [])
  end
end
