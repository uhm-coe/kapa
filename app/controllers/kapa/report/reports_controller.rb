class Kapa::Report::ReportsController < Kapa::KapaBaseController
  def index
    @datasets = Dataset.all
  end

  def show
    @dataset = Dataset.find(params[:id])
    @dataset.load if @dataset.loaded_at.blank?
    @parameters = @dataset.deserialize(:parameters)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @dataset }
    end
  end
end
