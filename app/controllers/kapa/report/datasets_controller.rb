class Kapa::Report::DatasetsController < Kapa::KapaBaseController

  def index
    @datasets = Dataset.all
  end

  def show
    @dataset = Dataset.find(params[:id])
    @parameters = @dataset.deserialize(:parameters, :as => OpenStruct)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @dataset }
    end
  end

  def new
    @dataset = Dataset.new
  end


  def create
    @dataset = Dataset.new(params[:dataset])

    # Create parameters based on attributes
    if @dataset.attr.present?
      params_hash = Hash.new
      attributes = @dataset.attr.split(",")
      attributes.each_with_index do |attribute, i|
        i = i + 1
        params_hash["name#{i}"] = attribute
        params_hash["type#{i}"] = "text_field"
        params_hash["default#{i}"] = attribute
        params_hash["label#{i}"] = attribute
        params_hash["active#{i}"] = "N"
      end
      params_hash["length"] = attributes.length
      @dataset.serialize(:parameters, params_hash)
    end

    unless @dataset.save
      flash[:danger] = @dataset.errors.full_messages.join(", ")
      redirect_to new_kapa_report_dataset_path and return false
    end
    flash[:success] = "Dataset was successfully created."
    redirect_to kapa_report_dataset_path(:id => @dataset)
  end

  def update
    @dataset = Dataset.find(params[:id])
    @dataset.serialize(:parameters, params[:parameters]) if params[:parameters]

    if @dataset.update_attributes(params[:dataset])
      flash[:success] = "Dataset was successfully updated."
    else
      flash[:danger] = @dataset.errors.full_messages.join(", ")
    end
    redirect_to kapa_report_dataset_path(:id => @dataset, :focus => params[:focus], :parameter_panel => params[:parameter_panel])
  end

  def destroy
    @dataset = Dataset.find(params[:id])
    @dataset.destroy

    redirect_to kapa_report_datasets_url
  end

  def load
    begin
      @dataset = Dataset.find(params[:id])
      @dataset.load
      flash[:success] = "Dataset was successfully loaded."
    rescue Sequel::Error => e
      flash[:danger] = e.message
    end

    redirect_to kapa_report_dataset_path(@dataset)
  end

  def feed
    @dataset = Dataset.find(params[:id])
    render :json => @dataset.to_json
  end
end
