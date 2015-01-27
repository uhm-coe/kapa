class Report::ReportsController < ApplicationBaseController
  def index
    @data_sets = DataSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @data_sets }
    end
  end

  def show
    @data_set = DataSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @data_set }
    end
  end
end
