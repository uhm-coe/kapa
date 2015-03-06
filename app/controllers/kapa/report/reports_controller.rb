class Kapa::Report::ReportsController < Kapa::KapaBaseController
  def index
    @datasets = Dataset.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @datasets }
    end
  end

  def show
    @dataset = Dataset.find(params[:id])
    @dataset.load if @dataset.loaded_at.blank?
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @dataset }
    end
  end
end
