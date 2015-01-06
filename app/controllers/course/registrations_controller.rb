class Course::RegistrationsController < Course::BaseController

  def show
    @filter = filter(request.get? ? {:assessment_rubric_id => nil} : {})
    @assessment_course_registration = AssessmentCourseRegistration.find(params[:id])
    @assessment_course = @assessment_course_registration.assessment_course
    @person = @assessment_course_registration.person
    @person.details(self)
    @assessment_rubrics = @assessment_course.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    @table = AssessmentScore.table_for(@assessment_rubric, "AssessmentCourseRegistration", params[:id])
  end

  def update
    params[:assessment_scores].each_pair do |k, v|
      scorable_id = k.split("_").first
      criterion_id = k.split("_").last
#      logger.debug "--scorable_id: #{scorable_id}, criterion_id: #{criterion_id}"
      score = AssessmentScore.find_or_initialize_by_assessment_scorable_type_and_assessment_scorable_id_and_assessment_criterion_id("AssessmentCourseRegistration", scorable_id, criterion_id)
#      logger.debug "--score: #{score.inspect}"
      score.rating = v
      score.rated_by = @current_user.uid
      unless score.save
        flash[:danger] = "There was an error updating scores. Please try again."
        # TODO: Fix redirect_to path
        redirect_to course_registration_path(:id => params[:id]) and return false
      end
    end

    flash[:success] = "Scores are successfully saved on #{DateTime.now.strftime("%H:%M:%S")}"
    # TODO: Fix redirect_to path
    redirect_to course_registration_path(:id => params[:id])
  end

end
