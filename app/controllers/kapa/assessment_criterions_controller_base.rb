module Kapa::AssessmentCriterionsControllerBase
  extend ActiveSupport::Concern

  def update
    @assessment_criterion = Kapa::AssessmentCriterion.find(params[:id])
    @assessment_criterion.attributes = assessment_criterion_params
    @assessment_criterion.update_serialized_attributes!(:_ext, params[:assessment_criterion_ext]) if params[:assessment_criterion_ext].present?

    if @assessment_criterion.save
      flash[:success] = "Criterion was successfully updated."
    else
      flash[:danger] = @assessment_criterion.errors.full_messages.join(", ")
    end
    redirect_to kapa_assessment_rubric_path(:id => @assessment_criterion.assessment_rubric_id, :anchor => params[:anchor], :criterion_panel => params[:criterion_panel])
  end

  def create
    @assessment_criterion = Kapa::AssessmentCriterion.new(:assessment_rubric_id => params[:id])
    @assessment_criterion.attributes = assessment_criterion_params

    if @assessment_criterion.save
      flash[:success] = "Criterion was successfully created."
    else
      flash[:danger] = @assessment_criterion.errors.full_messages.join(", ")
    end
    redirect_to kapa_assessment_rubric_path(:id => @assessment_criterion.assessment_rubric_id, :anchor => params[:anchor], :criterion_panel => @assessment_criterion.id)
  end

  def destroy
    @assessment_criterion = Kapa::AssessmentCriterion.find(params[:id])
    unless @assessment_criterion.assessment_scores.blank?
      flash[:warning] = "Criterion cannot be deleted since there are associated score entries."
      redirect_to kapa_assessment_rubric_path(:id => @assessment_criterion.assessment_rubric_id, :anchor => params[:anchor]) and return false
    end
    unless @assessment_criterion.destroy
      flash[:danger] = @assessment_criterion.errors.full_messages.join(", ")
      redirect_to kapa_assessment_rubric_path(:id => @assessment_criterion.assessment_rubric_id, :anchor => params[:anchor]) and return false
    end
    flash[:success] = "Criterion was successfully deleted."
    redirect_to kapa_assessment_rubric_path(:id => @assessment_criterion.assessment_rubric_id, :anchor => params[:anchor])
  end

  private
  def assessment_criterion_params
    params.require(:assessment_criterion).permit(:criterion, :criterion_desc, :standard, :type, :type_option)
  end
end
