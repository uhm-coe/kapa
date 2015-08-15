module Kapa::Document::FilesControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @files = Kapa::File.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def show
    @file = Kapa::File.find(params[:id])
    @person = @file.person
    @title = @file.name

    respond_to do |format|
      format.file {
        disposition = params[:inline] ? "inline" : "attachment"
        send_file @file.data.path,
                  :filename => @file.name,
                  :type => @file.content_type,
                  :disposition => disposition
      }
    end
  end

  def update
    @file = Kapa::File.find(params[:id])
    @person = @file.person
    @file.attributes=(params[:file])
    if params[:file][:data]
      @file.name = @file.data_file_name.humanize
      @file.uploaded_by = @current_user.uid
      @file.dept = @current_user.primary_dept
    end

    if @file.save
      flash[:success] = "Document was successfully updated."
    else
      flash[:danger] = error_message_for(@file)
    end
    redirect_to kapa_main_person_path(:id => @person, :artifacts_modal => "show")
  end

  def create
    if params[:file][:data].nil?
      flash[:warning] = "No file was specified. Please select a file to upload."
      params[:return_url][:artifacts_modal] = "show"
      redirect_to params[:return_url] and return false
    end

    @person = Kapa::Person.find(params[:id])
    @file = @person.files.build(params[:file])

    doc_name = params[:file][:name]
    @file.name = doc_name.blank? ? @file.data_file_name : doc_name
    @file.uploaded_by = @current_user.uid
    @file.dept = @current_user.primary_dept
    unless @file.save
      flash[:danger] = error_message_for(@file)
#      params[:return_url][:artifacts_modal] = "show"
      redirect_to params[:return_url] and return false
    end

    flash[:success] = "File was successfully uploaded."
#    params[:return_url][:artifacts_modal] = "show"
    redirect_to params[:return_url]
  end

  def destroy
    @file = Kapa::File.find(params[:id])

    if @file.destroy
      flash[:success] = "File was successfully deleted."
    else
      flash[:danger] = error_message_for(@file)
    end
    redirect_to kapa_main_person_path(:id => @file.person_id, :artifacts_modal => "show")
  end
end
