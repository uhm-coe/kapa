class Kapa::Report::DataSourcesController < Kapa::ApplicationBaseController
  # GET /data_sources
  # GET /data_sources.json
  def index
    @data_sources = DataSource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @data_sources }
    end
  end

  # GET /data_sources/1
  # GET /data_sources/1.json
  def show
    @data_source = DataSource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @data_source }
    end
  end

  # GET /data_sources/new
  # GET /data_sources/new.json
  def new
    @data_source = DataSource.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @data_source }
    end
  end

  # GET /data_sources/1/edit
  def edit
    @data_source = DataSource.find(params[:id])
  end

  # POST /data_sources
  # POST /data_sources.json
  def create
    @data_source = DataSource.new(params[:data_source])

    respond_to do |format|
      if @data_source.save
        format.html { redirect_to @data_source, :notice => 'DataSource was successfully created.' }
        format.json { render :json => @data_source, :status => :created, :location => @data_source }
      else
        format.html { render :action => "new" }
        format.json { render :json => @data_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /data_sources/1
  # PUT /data_sources/1.json
  def update
    @data_source = DataSource.find(params[:id])

    respond_to do |format|
      if @data_source.update_attributes(params[:data_source])
        format.html { redirect_to @data_source, :notice => 'DataSource was successfully updated.' }
        format.json { render :head => :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @data_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /data_sources/1
  # DELETE /data_sources/1.json
  def destroy
    @data_source = DataSource.find(params[:id])
    @data_source.destroy

    respond_to do |format|
      format.html { redirect_to kapa_data_sources_url }
      format.json { head :no_content }
    end
  end
end
