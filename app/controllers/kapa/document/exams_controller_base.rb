module Kapa::Document::ExamsControllerBase
  extend ActiveSupport::Concern

  def show
    @exam = Kapa::Exam.find(params[:id])
    @exam_scores = @exam.exam_scores
    @person = @exam.person
    @title = @exam.type_desc
    render :layout => "/kapa/layouts/document"
  end

  def update
    @exam = Kapa::Exam.find params[:id]
    @exam.attributes = params[:exam]
    if @exam.save
      flash[:success] = "Test record was updated."
    else
      flash[:danger] = error_message_for(@exam)
    end
    redirect_to kapa_document_exam_path(:id => @exam)
  end

  def destroy
    @exam = Kapa::Exam.find params[:id]
    unless @exam.destroy and @exam.exam_scores.clear
      flash[:danger] = error_message_for(@exam)
      redirect_to kapa_document_exam_path(:id => @exam) and return false
    end
    flash[:success] = "Test record was successfully deleted."
    redirect_to kapa_main_persons_path(:action => :show, :id => @exam.person_id, :focus => :exam)
  end

  def index
    @filter = filter
    @exams = Kapa::Exam.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def import
    @exams = []
    import_file = params[:data][:import_file]
    unless import_file
      flash[:warning] = "Please specify the file you are importing!"
      redirect_to(kapa_error_path) and return false
    end

    import_file.open.each do |line|
      exam = Kapa::Exam.new(:raw => line, :dept => @current_user.primary_dept, :type => params[:data][:type])

      unless exam.check_format
        flash[:warning] = "Invalid file format!"
        redirect_to :action => :index and return false
      end

      existing_exam = Kapa::Exam.find_by_report_number(exam.extract_report_number)
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
