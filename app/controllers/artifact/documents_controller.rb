class Artifact::DocumentsController < Artifact::BaseController

  def show
    @document = Document.find(params[:id])
    @person = @document.person
    @title = @document.name
    
    respond_to do |format|
      format.html {render :layout => "artifact"}
      format.file {
        disposition = params[:inline] ? "inline" : "attachment"
          send_file @document.data.path,
            :filename => @document.name,
            :type => @document.content_type,
            :disposition  => disposition  
      }
    end
  end

  def update
    @document = Document.find(params[:id])
    @person = @document.person
    @document.attributes=(params[:document])
    if params[:document][:data]
      @document.name = @document.data_file_name.humanize
      @document.uploaded_by = @current_user.uid
      @document.dept = @current_user.primary_dept
    end

    unless @document.save
      flash.now[:notice1] = error_message_for(@document)
      render_notice and return false
    end
    flash[:notice1] = "Document was successfully updated."
    redirect_to :action => :show, :id => @document
  end

  def create
    if params[:document].nil?
      flash[:notice] = "No file was specified! Please select a file you are uploading."
      redirect_to(error_path) and return false
    end
    
    @person = Person.find(params[:id])
    @document = @person.documents.build(params[:document])

    @document.name = @document.data_file_name
    @document.uploaded_by = @current_user.uid
    @document.dept = @current_user.primary_dept
    unless @document.save
      flash.now[:notice] = error_message_for(@document)
      redirect_to(error_path) and return false
    end

    flash[:notice] = 'Document was created.'
    params[:return_url][:focus] = params[:focus]
    redirect_to params[:return_url]
  end

  def destroy
    @document = Document.find(params[:id])
    unless @document.destroy
      flash.now[:notice1] = error_message_for(@document)
      render_notice and return false
    end
    flash[:notice1] = "Document was successfully deleted."
    redirect_to main_persons_path(:action => :show, :id => @document.person_id)
  end
end
