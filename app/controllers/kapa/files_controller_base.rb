module Kapa::FilesControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @files = Kapa::File.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def show
    @file = Kapa::File.find(params[:id])
    @file_ext = @file.ext
    @person = @file.person
    @person_ext = @person.ext
    @title = @file.name

    respond_to do |format|
      format.html {render :layout => "/kapa/layouts/document"}
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
    @file.attributes = file_param
    @file.update_serialized_attributes!(:_ext, params[:file_ext]) if params[:file_ext].present?
    if params[:file][:data]
      @file.name = @file.data_file_name.humanize
      @file.uploaded_by = @current_user.uid
      @file.dept = [@current_user.primary_dept]
    end

    if @file.save
      flash[:success] = "Document was successfully updated."
    else
      flash[:danger] = error_message_for(@file)
    end
    redirect_to kapa_person_path(:id => @person, :artifacts_modal => "show")
  end

  def create
    if params[:file][:data].nil?
      flash[:warning] = "No file was specified. Please select a file to upload."
      redirect_to params[:return_path] and return false
    end

    @file = Kapa::File.new(file_param)
    @file.name = @file.data_file_name if @file.name.blank?
    @file.uploaded_by = @current_user.uid
    @file.dept = [@current_user.primary_dept]
    unless @file.save
      flash[:danger] = error_message_for(@file)
      redirect_to params[:return_path] and return false
    end

    flash[:success] = "File was successfully uploaded."
    redirect_to params[:return_path]
  end

  def destroy
    @file = Kapa::File.find(params[:id])

    if @file.destroy
      flash[:success] = "File was successfully deleted."
    else
      flash[:danger] = error_message_for(@file)
    end
    render(:text => "<script>close();</script>")
  end

  def file_param
    params.require(:file).permit(:person_id, :attachable_id, :attachable_type, :data, :name, :lock, :note, :public)
  end
end
