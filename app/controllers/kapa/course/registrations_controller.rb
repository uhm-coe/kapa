class Kapa::Course::RegistrationsController < Kapa::Course::BaseController

  def show
    @filter = filter(request.get? ? {:assessment_rubric_id => nil} : {})
    @course_registration = CourseRegistration.find(params[:id])
    @course_offer = @course_registration.course_offer
    @person = @course_registration.person
    @person.details(self)
    @assessment_rubrics = @course_offer.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    @table = AssessmentScore.table_for(@assessment_rubric, "CourseRegistration", params[:id])
  end

  def update
    if params[:assessment_scores]
      params[:assessment_scores].each_pair do |k, v|
        scorable_id = k.split("_").first
        criterion_id = k.split("_").last
  #      logger.debug "--scorable_id: #{scorable_id}, criterion_id: #{criterion_id}"
        score = AssessmentScore.find_or_initialize_by_assessment_scorable_type_and_assessment_scorable_id_and_assessment_criterion_id("CourseRegistration", scorable_id, criterion_id)
  #      logger.debug "--score: #{score.inspect}"
        score.rating = v
        score.rated_by = @current_user.uid
        unless score.save
          flash[:danger] = "There was an error updating scores. Please try again."
          redirect_to kapa_course_registration_path(:id => params[:id], :focus => params[:focus]) and return false
        end
      end
      flash[:success] = "Scores were successfully saved on #{DateTime.now.strftime("%H:%M:%S")}"
    end

    if flash[:success].nil?
      flash[:warning] = "There are no scores to save."
    end
    redirect_to kapa_course_registration_path(:id => params[:id], :focus => params[:focus])
  end

end
