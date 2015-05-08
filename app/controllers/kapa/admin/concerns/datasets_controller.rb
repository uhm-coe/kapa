module Kapa::Admin::Concerns::DatasetsController
  extend ActiveSupport::Concern

  def index
    @datasets = Kapa::Dataset.all
  end

  def show
    @dataset = Kapa::Dataset.find(params[:id])
    @parameters = @dataset.deserialize(:parameters)
    if @dataset.attr.present?
      @attr_options = @dataset.attr.split(/,\s*/).collect { |a| [a, a] }
    else
      @attr_options = [["N/A", "Not Defined"]]
    end
  end

  def new
    @dataset = Kapa::Dataset.new
  end

  def create
    @dataset = Kapa::Dataset.new(params[:dataset])
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
        @parameters[params[:parameter_id].to_sym] = params[:parameter]
      else
        new_id = @parameters.length + 1
        @parameters[new_id.to_s.to_sym] = params[:parameter]
      end
      @dataset.serialize(:parameters, @parameters)
    end

    if @dataset.update_attributes(params[:dataset])
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

  def load
    begin
      @dataset = Kapa::Dataset.find(params[:id])
      @dataset.load
      flash[:success] = "Dataset was successfully loaded."

        ## Create parameters based on attributes
        #if @dataset.attr.present?
        #  params_hash = Hash.new
        #  attributes = @dataset.attr.split(",")
        #  attributes.each_with_index do |attribute, i|
        #    i = i + 1
        #    params_hash["name#{i}"] = attribute
        #    params_hash["type#{i}"] = "text_field"
        #    params_hash["default#{i}"] = attribute
        #    params_hash["label#{i}"] = attribute
        #    params_hash["active#{i}"] = "N"
        #  end
        #  params_hash["length"] = attributes.length
        #  @dataset.serialize(:parameters, params_hash)
        #
        #  unless @dataset.save
        #    flash[:success] = nil
        #    flash[:warning] = "Dataset was successfully loaded but could not create parameters."
        #  end
        #end
    rescue Sequel::Error => e
      flash[:danger] = e.message
    end

    redirect_to kapa_admin_dataset_path(@dataset)
  end

  def feed
    @dataset = Kapa::Dataset.find(params[:id])
    render :json => @dataset.to_json(params[:filter])
  end
end
