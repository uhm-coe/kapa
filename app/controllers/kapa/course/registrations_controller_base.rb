module Kapa::Course::RegistrationsControllerBase
  extend ActiveSupport::Concern

  def show
    @filter = filter(request.get? ? {:assessment_rubric_id => nil} : {})
    @course_registration = Kapa::CourseRegistration.find(params[:id])
    @course_offer = @course_registration.course_offer
    @person = @course_registration.person
    @person.details(self)
    @assessment_rubrics = @course_offer.assessment_rubrics
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
          redirect_to kapa_course_registration_path(:id => params[:id], :focus => params[:focus]) and return false
        end
        flash[:success] = "Scores were successfully saved."
      end
    end

    if flash[:success].nil?
      flash[:warning] = "There are no scores to save."
    end
    redirect_to kapa_course_registration_path(:id => params[:id], :focus => params[:focus])
  end
end
