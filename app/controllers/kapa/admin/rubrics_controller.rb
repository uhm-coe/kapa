class Kapa::Admin::RubricsController < Kapa::Admin::BaseController

  def show
    @assessment_rubric = AssessmentRubric.find(params[:id])
    @assessment_criterions = @assessment_rubric.assessment_criterions
  end

  def new
    @assessment_rubric = AssessmentRubric.new
  end

  def update
    @assessment_rubric = AssessmentRubric.find(params[:id])
    @assessment_rubric.attributes = params[:assessment_rubric]
    if @assessment_rubric.save
      flash[:success] = "Rubric was successfully updated."
    else
      flash[:danger] = @assessment_rubric.errors.full_messages.join(", ")
    end
    redirect_to kapa_admin_rubric_path(:id => @assessment_rubric)
  end

  def create
    @assessment_rubric = AssessmentRubric.new
    @assessment_rubric.attributes= params[:assessment_rubric]
    unless @assessment_rubric.save
      flash[:danger] = @assessment_rubric.errors.full_messages.join(", ")
      redirect_to new_kapa_admin_rubric_path and return false
    end
    flash[:success] = "Rubric was successfully created."
    redirect_to kapa_admin_rubric_path(:id => @assessment_rubric)
  end

  def destroy
    @assessment_rubric = AssessmentRubric.find(params[:id])
    unless @assessment_rubric.assessment_criterions.blank?
      flash[:danger] = "Rubric can not be deleted since it contains one or more criteria."
      redirect_to kapa_admin_rubric_path(:id => @assessment_rubric) and return false
    end
    unless @assessment_rubric.destroy
      flash[:danger] = @assessment_rubric.errors.full_messages.join(", ")
      redirect_to kapa_admin_rubric_path(:id => @assessment_rubric) and return false
    end
    flash[:success] = "Rubric was successfully deleted."
    redirect_to kapa_admin_rubrics_path
  end

  def index
    @filter = filter
    @per_page_selected = @filter.per_page || Rails.configuration.items_per_page
    @assessment_rubrics = AssessmentRubric.search(@filter).order("dept, title").paginate(:page => params[:page], :per_page => @per_page_selected)
  end

end
