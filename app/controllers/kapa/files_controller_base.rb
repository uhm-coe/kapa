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
    @document_title = @file.title
    @document_id = @file.document_id
    @document_date = @file.date

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
      @file.dept = @current_user.primary_dept
    end

    if @file.save
      flash[:success] = "Document was successfully updated."
    else
      flash[:danger] = error_message_for(@file)
      logger.error "*ERROR* File upload error: #{@file.inspect}"
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
    @file.dept = @current_user.primary_dept
    unless @file.save
      flash[:danger] = error_message_for(@file)
      logger.error "*ERROR* File upload error: #{@file.inspect}"
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
    redirect_to params[:return_path] || session[:return_path]
  end

  def export
    @filter = filter
    format = {
      :document_id => [:document_id],
      :title => [:title],
      :id_number => [:person, :id_number],
      :last_name => [:person, :last_name],
      :first_name => [:person, :first_name],
      :cur_street => [:person, :cur_street],
      :cur_city => [:person, :cur_city],
      :cur_state => [:person, :cur_state],
      :cur_postal_code => [:person, :cur_postal_code],
      :cur_phone => [:person, :cur_phone],
      :email => [:person, :email],
      :email_alt => [:person, :email_alt],
      :updated => [:updated_at]
    }

    send_data Kapa::File.to_table(:filter => @filter, :as => :csv, :format => format),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "files_#{Date.today}.csv"
  end

  def file_param
    params.require(:file).permit(:person_id, :attachable_id, :attachable_type, :data, :name, :lock, :note, :public, :dept, :depts => [])
  end
end
