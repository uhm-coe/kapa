module Kapa::Document::ReportsControllerBase
  extend ActiveSupport::Concern

  def index
    @datasets = Kapa::Dataset.all
  end

  def show
    @dataset = Kapa::Dataset.find(params[:id])
    @dataset.load if @dataset.loaded_at.blank?
    @parameters = @dataset.deserialize(:parameters)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @dataset }
    end
  end
end
