class Admin::RubricsController < Admin::BaseController

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
    redirect_to admin_rubric_path(:id => @assessment_rubric)
  end

  def create
    @assessment_rubric = AssessmentRubric.new
    @assessment_rubric.attributes= params[:assessment_rubric]
    unless @assessment_rubric.save
      flash[:danger] = @assessment_rubric.errors.full_messages.join(", ")
      redirect_to new_admin_rubric_path and return false
    end
    flash[:success] = "Rubric was successfully created."
    redirect_to admin_rubric_path(:id => @assessment_rubric)
  end

  def destroy
    @assessment_rubric = AssessmentRubric.find(params[:id])
    unless @assessment_rubric.assessment_criterions.blank?
      flash[:danger] = "Rubric can not be deleted since it contains one or more criteria."
      redirect_to admin_rubric_path(:id => @assessment_rubric) and return false
    end
    unless @assessment_rubric.destroy
      flash[:danger] = @assessment_rubric.errors.full_messages.join(", ")
      redirect_to admin_rubric_path(:id => @assessment_rubric) and return false
    end
    flash[:success] = "Rubric was successfully deleted."
    redirect_to admin_rubrics_path
  end

  def index
    @filter = filter
    @filter.append_condition "assessment_rubrics.title like ?", :title, :like => true
    @filter.append_condition "assessment_rubrics.program like ?", :program, :like => true
    @filter.append_condition "assessment_rubrics.course like ?", :course, :like => true
    @filter.append_condition "assessment_rubrics.transition_point like ?", :transition_point, :like => true
    @assessment_rubrics = AssessmentRubric.paginate(:page => params[:page], :per_page => 20, :include => :assessment_criterions, :conditions => @filter.conditions, :order => "dept, title")
  end

end
