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

    if @document.save
      flash[:success] = "Document was successfully updated."
    else
      flash[:danger] = error_message_for(@document)
    end
    redirect_to artifact_document_path(:id => @document)
  end

  # TODO: "Upload a document" not working, throws ActiveRecord::UnknownAttributeError (unknown attribute: data)
  def create
    if params[:document][:data].nil?
      flash[:warning] = "No file was specified. Please select a file to upload."
      redirect_to params[:return_url] and return false
    end

    @person = Person.find(params[:id])
    @document = @person.documents.build(params[:document])

    doc_name = params[:document][:name]
    @document.name = doc_name.blank? ? @document.data_file_name : doc_name
    @document.uploaded_by = @current_user.uid
    @document.dept = @current_user.primary_dept
    unless @document.save
      flash[:danger] = error_message_for(@document)
      redirect_to params[:return_url] and return false
    end

    flash[:success] = "Document was successfully uploaded. Please verify that it is legible."
    params[:return_url][:focus] = params[:focus]
    redirect_to params[:return_url]
  end

  def destroy
    @document = Document.find(params[:id])
    unless @document.destroy
      flash[:danger] = error_message_for(@document)
      redirect_to artifact_document_path(:id => @document) and return false
    end
    flash[:success] = "Document was successfully deleted."
    redirect_to main_person_path(:id => @document.person_id)
  end
end
