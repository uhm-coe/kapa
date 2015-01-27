class Report::DataSetsController < ApplicationBaseController
  # GET /data_sets
  # GET /data_sets.json
  def index
    @data_sets = DataSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @data_sets }
    end
  end

  # GET /data_sets/1
  # GET /data_sets/1.json
  def show
    @data_set = DataSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @data_set }
    end
  end

  # GET /data_sets/new
  # GET /data_sets/new.json
  def new
    @data_set = DataSet.new
    @data_sources = DataSource.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @data_set }
    end
  end

  # GET /data_sets/1/edit
  def edit
    @data_set = DataSet.find(params[:id])
    @data_sources = DataSource.all
  end

  # POST /data_sets
  # POST /data_sets.json
  def create
    @data_set = DataSet.new(params[:data_set])

    respond_to do |format|
      if @data_set.save
        format.html { redirect_to @data_set, :notice => 'DataSet was successfully created.' }
        format.json { render :json => @data_set, :status => :created, :location => @data_set }
      else
        format.html { render :action => "new" }
        format.json { render :json => @data_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /data_sets/1
  # PUT /data_sets/1.json
  def update
    @data_set = DataSet.find(params[:id])

    respond_to do |format|
      if @data_set.update_attributes(params[:data_set])
        format.html { redirect_to @data_set, :notice => 'DataSet was successfully updated.' }
        format.json { render :head => no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @data_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /data_sets/1
  # DELETE /data_sets/1.json
  def destroy
    @data_set = DataSet.find(params[:id])
    @data_set.destroy

    respond_to do |format|
      format.html { redirect_to data_sets_url }
      format.json { head :no_content }
    end
  end

  def load
    begin
      @data_set = DataSet.find(params[:id])
      @data_set.load
      flash[:notice] = "DataSet was successfully loaded."
    rescue Sequel::Error => e
      flash[:error] = e.message
    end

    redirect_to data_set_path(@data_set)
  end

  def feed
    @data_set = DataSet.find(params[:id])
    render :json => @data_set.to_json
  end

end
