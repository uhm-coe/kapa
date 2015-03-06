class Kapa::Report::DatasetsController < Kapa::KapaBaseController

  def index
    @datasets = Dataset.all
  end

  def show
    @dataset = Dataset.find(params[:id])

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

    if @dataset.save
      redirect_to kapa_report_dataset_path(@dataset), :notice => 'Data Set was successfully created.'
    else
      render :action => "new"
    end
  end

  def update
    @dataset = Dataset.find(params[:id])

    if @dataset.update_attributes(params[:dataset])
      redirect_to kapa_report_dataset_path(@dataset), :notice => 'Dataset was successfully updated.'
    else
      render :action => "show"
    end
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
      flash[:notice] = "Dataset was successfully loaded."
    rescue Sequel::Error => e
      flash[:error] = e.message
    end

    redirect_to kapa_report_dataset_path(@dataset)
  end

  def feed
    @dataset = Dataset.find(params[:id])
    render :json => @dataset.to_json
  end
end
