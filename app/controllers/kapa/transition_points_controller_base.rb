module Kapa::TransitionPointsControllerBase
  extend ActiveSupport::Concern

  def show
    session[:filter][:assessment_rubric_id] = nil if session[:filter] and request.get?
    @filter = filter

    @transition_point = Kapa::TransitionPoint.find(params[:id])
    @transition_point_ext = @transition_point.ext
    @curriculum = @transition_point.curriculum
    @program = @curriculum.program
    @programs = Kapa::Program.where(:active => true)
    @transition_actions = @transition_point.transition_actions
    @person = @curriculum.person
    @person_ext = @person.ext

    @curriculums = @person.curriculums
    @assessment_rubrics = @transition_point.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? Kapa::AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    @scores = Kapa::AssessmentScore.scores([@transition_point], @assessment_rubric)
  end

  def update
    if params[:transition_point]
      @transition_point = Kapa::TransitionPoint.find(params[:id])
      @transition_point.attributes = transition_point_params
      @transition_point.update_serialized_attributes!(:_ext, params[:transition_point_ext]) if params[:transition_point_ext].present?

      unless @transition_point.save
        flash[:danger] = @transition_point.errors.full_messages.join(", ")
        redirect_to kapa_transition_point_path(:id => @transition_point, :anchor => params[:anchor]) and return false
      end
    end

    if params[:assessment_scores]
      params[:assessment_scores].each_pair do |k, v|
        scorable_id = k.split("_").first
        criterion_id = k.split("_").last
        score = Kapa::AssessmentScore.find_or_initialize_by(:assessment_scorable_type => "Kapa::TransitionPoint", :assessment_scorable_id => scorable_id, :assessment_criterion_id => criterion_id)
        score.rating = v
        score.rated_by = @current_user.uid
        unless score.save
          flash[:danger] = "There was an error updating scores. Please try again."
          redirect_to kapa_transition_point_path(:id => @transition_point, :anchor => params[:anchor]) and return false
        end
      end
    end

    flash[:success] = "Transition point was successfully updated."
    redirect_to kapa_transition_point_path(:id => @transition_point, :anchor => params[:anchor])
  end

  def new
    @curriculum = Kapa::Curriculum.find(params[:id])
    @person = @curriculum.person
    @curriculums = @person.curriculums
    @transition_point = @curriculum.transition_points.build(:term_id => Kapa::Term.current_term.id, :curriculum_id => params[:id])
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @curriculum = @person.curriculums.find(params[:transition_point][:curriculum_id])

    @transition_point = @curriculum.transition_points.build(transition_point_params)
    @transition_point.dept = [@current_user.primary_dept]
    @transition_point.active = true
    unless @transition_point.save
      flash[:danger] = @transition_point.errors.full_messages.join(", ")
      redirect_to new_kapa_transition_point_path(:id => @curriculum) and return false
    end
    flash[:success] = "Transition point was successfully created."
    redirect_to kapa_transition_point_path(:id => @transition_point)
  end

  def index
    @filter = filter(:type => "admission")
    logger.debug "*DEBUG* #{@filter.inspect}"
    @transition_points = Kapa::TransitionPoint.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::TransitionPoint.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "#{@filter.transition_point_type}_#{Kapa::Term.find(@filter.term_id).description if @filter.term_id.present?}.csv"
  end

  private
  def transition_point_params
    params.require(:transition_point).permit(:term_id, :type, :category, :priority, :status, :note, :assessment_note, :curriculum_id, :user_ids => [])
  end

  #def filter_defaults
  #  super.merge({
  #    :transition_point_type => "admission"
  #  })
  #end
end
