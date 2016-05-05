module Kapa::CoursesControllerBase
  extend ActiveSupport::Concern

  def show
#    session[:filter_course][:assessment_rubric_id] = nil if request.get? and params[:format] != "file"
    @filter = filter((request.get? and params[:format] != "file") ? {:assessment_rubric_id => nil} : {})
    @course = Kapa::Course.find(params[:id])
    @course_ext = @course.ext
    @assessment_rubrics = @course.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? Kapa::AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    @course_registrations = @course.course_registrations
    @scores = Kapa::AssessmentScore.scores(@course_registrations, @assessment_rubric)
    session[:scores] = @scores

    respond_to do |format|
      format.html
      format.file {
        csv_string = CSV.generate do |csv|
          title = [@course.name, @course.term_desc, @course.instructor, @assessment_rubric.title]
          csv << title
          header_row = [:id_number, :last_name, :first_name]
          @assessment_rubric.assessment_criterions.each { |c| header_row.push("#{c.criterion}:#{c.criterion_desc}") }
          csv << header_row

          @course_registrations.each do |r|
            row = [r.rsend(:person, :id_number),
                   r.rsend(:person, :last_name),
                   r.rsend(:person, :first_name)]
            @assessment_rubric.assessment_criterions.each { |c| row.push(@scores["#{r.id}_#{c.id}"]) }
            csv << row
          end
        end

        send_data csv_string,
                  :type => "application/csv",
                  :disposition => "inline",
                  :filename => "#{@course.name}_#{@course.term_desc}.csv"
      }
    end
  end

  def new
  end

  def create
    @course = Kapa::Course.new(course_params)

    unless @course.save
      flash[:danger] = error_message_for(@course)
      redirect_to new_kapa_course_path and return false
    end

    flash[:notice] = "Course was successfully created."
    redirect_to kapa_course_path(:id => @course)
  end

  def update
    @filter = filter
    if params[:assessment_scores]
      ActiveRecord::Base.transaction do
        begin
          params[:assessment_scores].each_pair do |k, v|
            #Skip update if score is the same as previous one
            if session[:scores][k] != v
              scorable_id = k.split("_").first
              criterion_id = k.split("_").last
              score = Kapa::AssessmentScore.find_or_initialize_by(:assessment_scorable_type => "Kapa::CourseRegistration", :assessment_scorable_id => scorable_id, :assessment_criterion_id => criterion_id)
              score.rating = v
              score.rated_by = @current_user.uid
              score.save!
            end
          end
        rescue ActiveRecord::StatementInvalid
          flash[:danger] = "There was an error updating scores. Please try again."
          redirect_to kapa_course_path(:id => params[:id], :assessment_rubric_id => @filter.assessment_rubric_id) and return false
        end
      end
    end
    redirect_to  kapa_course_path(:id => params[:id], :assessment_rubric_id => @filter.assessment_rubric_id)
  end

  def index
    @filter = filter
    @courses = Kapa::Course.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::Course.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "courses_#{Kapa::Term.find(@filter.term_id).description if @filter.term_id.present?}.csv"
  end

  def import
    errors = 0
    file = params[:data][:import_file]
    CSV.foreach(file.path, :headers => true) do |row|
      course = Kapa::Course.find_by(:subject => row["subject"], :number => row["number"], :term_id => row["term_id"])
      course = Kapa::Course.new(:subject => row["subject"], :number => row["number"], :term_id => row["term_id"]) if course.blank?
      course.crn = row["crn"]
      course.title = row["title"]
      course.instructor = row["instructor"]
      course.status = "A"
      course.credits = row["credits"]
      unless course.save
        errors = errors + 1
        logger.error "!!!!-- Failed to save course: #{course.errors.full_messages}"
      end
    end
    flash[:info] = "Courses were imported. Errors: #{errors}"
    redirect_to kapa_courses_path
  end

  private
  def course_params
    params.require(:course).permit(:academic_period, :crn, :subject, :number, :section, :title, :instructor, :status, :uml, :xml, :final_grade, :dept, :user_ids => [], :term_id, :credits)
  end
end
