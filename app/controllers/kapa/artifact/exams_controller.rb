class Kapa::Artifact::ExamsController < Kapa::Artifact::BaseController

  def show
    @exam = Exam.find(params[:id])
    @examinee_profile = @exam.examinee_profile
    @examinee_contact = @exam.examinee_contact
    @exam_scores = @exam.exam_scores
    @person = @exam.person
    @title = "Praxis Score Report"
    render :layout => "/kapa/layouts/artifact"
  end

  def update
    @exam = Exam.find params[:id]
    #attributes= was not used because I do not want to accidentally delete form.data
    @exam.note = params[:exam][:note] if not params[:exam][:note].blank?

    if @exam.save
      flash[:success] = "Exam was updated."
    else
      flash[:danger] = error_message_for(@exam)
    end
    redirect_to kapa_artifact_exam_path(:id => @exam)
  end

  def destroy
    @exam = Exam.find params[:id]
    unless @exam.destroy and @exam.exam_scores.clear
      flash[:danger] = error_message_for(@exam)
      redirect_to kapa_artifact_exam_path(:id => @exam) and return false
    end
    flash[:success] = "Exam was successfully deleted."
    redirect_to kapa_main_persons_path(:action => :show, :id => @exam.person_id, :focus => :exam)
  end

  def index
    @filter = filter
    @per_page_selected = @filter.per_page || Rails.configuration.items_per_page
    @exams = Exam.search(@filter).order("report_date DESC, persons.last_name, persons.first_name").paginate(:page => params[:page], :per_page => @per_page_selected)
  end

  def import
    @exams = []
    import_file = params[:data][:import_file]
    unless import_file
      flash[:warning] = "Please specify the file you are importing!"
      redirect_to(kapa_error_path) and return false
    end

    import_file.open.each do |line|
      exam = Exam.new(:raw => line, :dept => @current_user.primary_dept, :type => params[:data][:type])

      unless exam.check_format
        flash[:warning] = "Invalid file format!"
        redirect_to :action => :index and return false
      end

      existing_exam = Exam.find_by_report_number(exam.extract_report_number)
      if existing_exam
        exam = existing_exam
        exam.update_attribute(:raw, line)
      else
        exam.save
      end

      unless exam.parse
        flash[:danger] = "Error while parsing data!"
        redirect_to :action => :index and return false
      end

      @exams.push exam
    end

    flash[:success] = "#{@exams.length} records are imported."
    redirect_to :action => :index
  end

end
