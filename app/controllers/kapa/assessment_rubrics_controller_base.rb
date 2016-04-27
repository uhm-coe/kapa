module Kapa::AssessmentRubricsControllerBase
  extend ActiveSupport::Concern

  def show
    @assessment_rubric = Kapa::AssessmentRubric.find(params[:id])
    @assessment_rubric_ext = @assessment_rubric.ext
    @assessment_criterions = @assessment_rubric.assessment_criterions
  end

  def new
    @assessment_rubric = Kapa::AssessmentRubric.new
  end

  def update
    @assessment_rubric = Kapa::AssessmentRubric.find(params[:id])
    @assessment_rubric.attributes = assessment_rubric_params
    @assessment_rubric.update_serialized_attributes!(:_ext, params[:assessment_rubric_ext]) if params[:assessment_rubric_ext].present?
    if @assessment_rubric.save
      flash[:success] = "Rubric was successfully updated."
    else
      flash[:danger] = @assessment_rubric.errors.full_messages.join(", ")
    end
    redirect_to kapa_assessment_rubric_path(:id => @assessment_rubric)
  end

  def create
    @assessment_rubric = Kapa::AssessmentRubric.new
    @assessment_rubric.attributes= assessment_rubric_params
    unless @assessment_rubric.save
      flash[:danger] = @assessment_rubric.errors.full_messages.join(", ")
      redirect_to new_kapa_assessment_rubric_path and return false
    end
    flash[:success] = "Rubric was successfully created."
    redirect_to kapa_assessment_rubric_path(:id => @assessment_rubric)
  end

  def destroy
    @assessment_rubric = Kapa::AssessmentRubric.find(params[:id])
    unless @assessment_rubric.assessment_criterions.blank?
      flash[:danger] = "Rubric can not be deleted since it contains one or more criteria."
      redirect_to kapa_assessment_rubric_path(:id => @assessment_rubric) and return false
    end
    unless @assessment_rubric.destroy
      flash[:danger] = @assessment_rubric.errors.full_messages.join(", ")
      redirect_to kapa_assessment_rubric_path(:id => @assessment_rubric) and return false
    end
    flash[:success] = "Rubric was successfully deleted."
    redirect_to kapa_assessment_rubrics_path
  end

  def index
    @filter = filter
    @assessment_rubrics = Kapa::AssessmentRubric.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  private
  def assessment_rubric_params
    params.require(:assessment_rubric).permit(:title, :dept, :reference_url, :start_term_id, :end_term_id,
                                              :program=>[], :course=>[], :transition_point=>[])
  end
end
