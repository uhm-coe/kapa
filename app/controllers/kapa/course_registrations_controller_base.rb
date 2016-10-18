module Kapa::CourseRegistrationsControllerBase
  extend ActiveSupport::Concern

  def show
    @filter = filter(request.get? ? {:assessment_rubric_id => nil} : {})
    @course_registration = Kapa::CourseRegistration.find(params[:id])
    @course = @course_registration.course
    @person = @course_registration.person
    @person_ext = @person.ext
    @assessment_rubrics = @course.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? Kapa::AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    @scores = Kapa::AssessmentScore.scores([@course_registration], @assessment_rubric)
  end

  def update
    if params[:assessment_scores]
      ActiveRecord::Base.transaction do
        begin
          params[:assessment_scores].each_pair do |k, v|
            scorable_id = k.split("_").first
            criterion_id = k.split("_").last
            score = Kapa::AssessmentScore.find_or_initialize_by(:assessment_scorable_type => "Kapa::CourseRegistration", :assessment_scorable_id => scorable_id, :assessment_criterion_id => criterion_id)
            score.rating = v
            score.rated_by = @current_user.uid
            score.save!
          end
        rescue ActiveRecord::StatementInvalid
          flash[:danger] = "There was an error updating scores. Please try again."
          redirect_to kapa_course_registration_path(:id => params[:id], :anchor => params[:anchor]) and return false
        end
        flash[:success] = "Scores were successfully saved."
      end
    end

    if flash[:success].nil?
      flash[:warning] = "There are no scores to save."
    end
    redirect_to kapa_course_registration_path(:id => params[:id], :anchor => params[:anchor])
  end

  def new
    @person = Kapa::Person.find(params[:id])
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @course_registration = Kapa::CourseRegistration.new(course_registration_params)
    @course_registration.attributes = course_registration_params
    @course_registration.status = "R"
    @course_registration.person = @person

    unless @course_registration.save
      flash[:danger] = error_message_for(@course_registration)
      redirect_to new_kapa_course_registration_path(:id => @person) and return false
    end

    flash[:success] = "Course registration was successfully created."
    redirect_to kapa_advising_session_path(:id => params[:advising_session_id]) and return true if params[:advising_session_id].present?
    redirect_to kapa_course_registration_path(:id => @course_registration)
  end

  def destroy
    @course_registration = Kapa::CourseRegistration.find_by(:course_id => params[:course_id], :person_id => params[:person_id])
    @person = @course_registration.person

    unless @course_registration.destroy
      flash[:danger] = error_message_for(@course_registration)
      redirect_to kapa_course_registration_path(:id => @course_registration) and return false
    end

    flash[:success] = "Course registration was successfully deleted."
    redirect_to kapa_advising_session_path(:id => params[:advising_session_id]) and return true if params[:advising_session_id].present?
    redirect_to kapa_person_path(:id => @person)
  end

  private
  def course_registration_params
    params.require(:course_registration).permit(:course_id, :person_id, :status, :yml, :xml)
  end
end
