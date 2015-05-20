module Kapa::Admin::Concerns::DatasetsController
  extend ActiveSupport::Concern

  def index
    @datasets = Kapa::Dataset.all
  end

  def show
    @dataset = Kapa::Dataset.find(params[:id])
    @parameters = @dataset.deserialize(:parameters)
    @columns = @dataset.deserialize(:columns)
    @datasource_options = datasource_options
  end

  def new
    @dataset = Kapa::Dataset.new
    @datasource_options = datasource_options
  end

  def create
    @dataset = Kapa::Dataset.new(dataset_params)
    unless @dataset.save
      flash[:danger] = @dataset.errors.full_messages.join(", ")
      redirect_to new_kapa_admin_dataset_path and return false
    end
    flash[:success] = "Dataset was successfully created."
    redirect_to kapa_admin_dataset_path(:id => @dataset)
  end

  def update
    @dataset = Kapa::Dataset.find(params[:id])
    @parameters = @dataset.deserialize(:parameters)

    if params[:parameter]
      if params[:parameter_id]
        @parameters[params[:parameter_id].to_sym] = parameter_params
      else
        new_id = @parameters.length + 1
        @parameters[new_id.to_s.to_sym] = parameter_params
      end
      @dataset.serialize(:parameters, @parameters)
    end

    @dataset.attributes = dataset_params if params[:dataset]

    if @dataset.save
      flash[:success] = "Dataset was successfully updated."
    else
      flash[:danger] = @dataset.errors.full_messages.join(", ")
    end
    redirect_to kapa_admin_dataset_path(:id => @dataset, :focus => params[:focus], :parameter_panel => params[:parameter_panel])
  end

  def destroy
    @dataset = Kapa::Dataset.find(params[:id])
    @dataset.destroy

    redirect_to kapa_report_datasets_url
  end

  def load_data
    @dataset = Kapa::Dataset.find(params[:id])
    @dataset.update_attributes(dataset_params)

    begin
      @dataset.load
      flash[:success] = "Dataset was successfully loaded."

    rescue Sequel::Error => e
      flash[:danger] = e.message
    end

    redirect_to kapa_admin_dataset_path(@dataset, :focus => params[:focus])
  end

  def feed
    @dataset = Kapa::Dataset.find(params[:id])
    render :json => @dataset.to_json(params[:filter])
  end

  def datasource_options
    datasources = [["Local Database", "local"], ["CSV File", "file"]]
    Rails.application.secrets.datasources.each_pair do |k, v|
      datasources.push [v["name"], k]
    end
    return datasources
  end

  private
  def dataset_params
    params.require(:dataset).permit(:name, :type, :datasource, :description, :query, :ldap_base, :ldap_filter, :ldap_attr)
  end

  def parameter_params
    params.require(:parameter).permit(:name, :type, :label, :default, :active)
  end
end
