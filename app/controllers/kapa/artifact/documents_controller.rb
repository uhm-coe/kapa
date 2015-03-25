class Kapa::Artifact::DocumentsController < Kapa::Artifact::BaseController

  def show
    @document = Document.find(params[:id])
    @person = @document.person
    @title = @document.name

    respond_to do |format|
      format.file {
        disposition = params[:inline] ? "inline" : "attachment"
        send_file @document.data.path,
                  :filename => @document.name,
                  :type => @document.content_type,
                  :disposition => disposition
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
    redirect_to kapa_main_person_path(:id => @person, :artifacts_modal => "show")
  end

  def create
    if params[:document][:data].nil?
      flash[:warning] = "No file was specified. Please select a file to upload."
      params[:return_url][:artifacts_modal] = "show"
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
      params[:return_url][:artifacts_modal] = "show"
      redirect_to params[:return_url] and return false
    end

    flash[:success] = "Document was successfully uploaded."
    params[:return_url][:artifacts_modal] = "show"
    redirect_to params[:return_url]
  end

  def destroy
    @document = Document.find(params[:id])

    if @document.destroy
      flash[:success] = "Document was successfully deleted."
    else
      flash[:danger] = error_message_for(@document)
    end
    redirect_to kapa_main_person_path(:id => @document.person_id, :artifacts_modal => "show")
  end
end
