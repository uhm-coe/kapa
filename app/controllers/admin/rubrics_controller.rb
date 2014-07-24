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
    unless @assessment_rubric.save
      flash.now[:notice1] = @assessment_rubric.errors.full_messages.join(", ")
      render_notice and return false
    end
    flash[:notice1] = "Rubric was successfully updated."
    render_notice
  end

  def create
    @assessment_rubric = AssessmentRubric.new
    @assessment_rubric.attributes= params[:assessment_rubric]
    unless @assessment_rubric.save
      flash.now[:notice1] = @assessment_rubric.errors.full_messages.join(", ")
      render_notice and return false
    end
    flash[:notice1] = "Rubric was successfully created."
    redirect_to :action => :show, :id => @assessment_rubric
  end

  def destroy
    @assessment_rubric = AssessmentRubric.find(params[:id])
    unless @assessment_rubric.assessment_criterions.blank?
      flash.now[:notice1] = "Rubric can not be deleted since it contains one or more criteria."
      render_notice and return false
    end
    unless @assessment_rubric.destroy
      flash.now[:notice1] = @assessment_rubric.errors.full_messages.join(", ")
      render_notice and return false
    end
    flash[:notice1] = "Rubric was successfully deleted."
    redirect_to :action => :list
  end

  def list
    @filter = filter
    @filter.append_condition "assessment_rubrics.title like ?", :title, :like => true
    @filter.append_condition "assessment_rubrics.program like ?", :program, :like => true
    @filter.append_condition "assessment_rubrics.course like ?", :assessment_course, :like => true
    @filter.append_condition "assessment_rubrics.transition_point like ?", :transition_point, :like => true
    @assessment_rubrics = AssessmentRubric.paginate(:page => params[:page], :per_page => 20, :include => :assessment_criterions, :conditions => @filter.conditions, :order => "dept, title")
  end

end
