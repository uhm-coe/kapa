module Kapa::Admin::CriterionsControllerBase
  extend ActiveSupport::Concern

  def update
    @assessment_criterion = Kapa::AssessmentCriterion.find(params[:id])
    @assessment_criterion.attributes = params[:assessment_criterion]

    if @assessment_criterion.save
      flash[:success] = "Criterion was successfully updated."
    else
      flash[:danger] = @assessment_criterion.errors.full_messages.join(", ")
    end
    redirect_to kapa_admin_rubric_path(:id => @assessment_criterion.assessment_rubric_id, :focus => params[:focus], :criterion_panel => params[:criterion_panel])
  end

  def create
    @assessment_criterion = Kapa::AssessmentCriterion.new(:assessment_rubric_id => params[:id])
    @assessment_criterion.attributes = params[:assessment_criterion]

    if @assessment_criterion.save
      flash[:success] = "Criterion was successfully created."
    else
      flash[:danger] = @assessment_criterion.errors.full_messages.join(", ")
    end
    redirect_to kapa_admin_rubric_path(:id => @assessment_criterion.assessment_rubric_id, :focus => params[:focus], :criterion_panel => @assessment_criterion.id)
  end

  def destroy
    @assessment_criterion = Kapa::AssessmentCriterion.find(params[:id])
    unless @assessment_criterion.assessment_scores.blank?
      flash[:warning] = "Criterion cannot be deleted since there are associated score entries."
      redirect_to kapa_admin_rubric_path(:id => @assessment_criterion.assessment_rubric_id, :focus => params[:focus]) and return false
    end
    unless @assessment_criterion.destroy
      flash[:danger] = @assessment_criterion.errors.full_messages.join(", ")
      redirect_to kapa_admin_rubric_path(:id => @assessment_criterion.assessment_rubric_id, :focus => params[:focus]) and return false
    end
    flash[:success] = "Criterion was successfully deleted."
    redirect_to kapa_admin_rubric_path(:id => @assessment_criterion.assessment_rubric_id, :focus => params[:focus])
  end
end
