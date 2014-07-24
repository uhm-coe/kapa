class Admin::CriterionsController < Admin::BaseController
  
  def update
    @assessment_criterion = AssessmentCriterion.find(params[:id])
    @assessment_criterion.attributes = params[:assessment_criterion]
    unless @assessment_criterion.save
      flash.now[:notice1] = @assessment_criterion.errors.full_messages.join(", ")
      render_notice and return false
    end
    flash[:notice1] = "Criterion was successfully updated."
    render_notice
  end

  def create
    @assessment_criterion = AssessmentCriterion.new(:assessment_rubric_id => params[:id])
    @assessment_criterion.attributes = params[:assessment_criterion]

    unless @assessment_criterion.save
      flash.now[:notice1] = @assessment_criterion.errors.full_messages.join(", ")
      render_notice and return false
    end
    flash[:notice1] = "Criterion was successfully created."
    redirect_to admin_rubrics_path(:action => :show, :id => @assessment_criterion.assessment_rubric_id, :focus => "criterions")
  end

  def destroy
    @assessment_criterion = AssessmentCriterion.find(params[:id])
    unless @assessment_criterion.assessment_scores.blank?
      flash[:notice1] = "Criterion cannot be deleted since there are associated score entries."
      redirect_to admin_rubrics_path(:action => :show, :id => @assessment_criterion.assessment_rubric_id, :focus => "criterions") and return false
    end
    unless @assessment_criterion.destroy
      flash[:notice1] = @assessment_criterion.errors.full_messages.join(", ")
      redirect_to admin_rubrics_path(:action => :show, :id => @assessment_criterion.assessment_rubric_id, :focus => "criterions") and return false
    end
    flash[:notice1] = "Criterion was successfully deleted."
    redirect_to admin_rubrics_path(:action => :show, :id => @assessment_criterion.assessment_rubric_id, :focus => "criterions")
  end
  
end
