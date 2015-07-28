module Kapa::Main::TransitionPointsControllerBase
  extend ActiveSupport::Concern

  def show
    session[:filter_main][:assessment_rubric_id] = nil if session[:filter_main] and request.get?
    @filter = filter

    @transition_point = Kapa::TransitionPoint.find(params[:id])
    @transition_point_ext = @transition_point.deserialize(:_ext, :as => OpenStruct)
    @curriculum = @transition_point.curriculum
    @program = @curriculum.program
    @programs = Kapa::Program.where(:active => true)
    @transition_actions = @transition_point.transition_actions
    @person = @curriculum.person
    @person.details(self)
    @curriculums = @person.curriculums
    @assessment_rubrics = @transition_point.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? Kapa::AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    @table = Kapa::AssessmentScore.table_for(@assessment_rubric, "TransitionPoint", @transition_point.id)
  end

  def update
    if params[:transition_point]
      @transition_point = Kapa::TransitionPoint.find(params[:id])
      @transition_point.attributes = params[:transition_point]
      @transition_point.update_serialized_attributes(:_ext, params[:transition_point_ext])

      unless @transition_point.save
        flash[:danger] = @transition_point.errors.full_messages.join(", ")
        redirect_to kapa_main_transition_point_path(:id => @transition_point, :focus => params[:focus]) and return false
      end
    end

    if params[:assessment_scores]
      params[:assessment_scores].each_pair do |k, v|
        scorable_id = k.split("_").first
        criterion_id = k.split("_").last
        score = Kapa::AssessmentScore.find_or_initialize_by_assessment_scorable_type_and_assessment_scorable_id_and_assessment_criterion_id("TransitionPoint", scorable_id, criterion_id)
        score.rating = v
        score.rated_by = @current_user.uid
        unless score.save
          flash[:danger] = "There was an error updating scores. Please try again."
          redirect_to kapa_main_transition_point_path(:id => @transition_point, :focus => params[:focus]) and return false
        end
      end
    end

    flash[:success] = "Transition point was successfully updated."
    redirect_to kapa_main_transition_point_path(:id => @transition_point, :focus => params[:focus])
  end

  def new
    @curriculum = Kapa::Curriculum.find(params[:id])
    @person = @curriculum.person
    @person.details(self)
    @curriculums = @person.curriculums
    @transition_point = @curriculum.transition_points.build(:term_id => Kapa::Term.current_term.id, :curriculum_id => params[:id])
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @curriculum = @person.curriculums.find(params[:transition_point][:curriculum_id])

    @transition_point = @curriculum.transition_points.build(params[:transition_point])
    @transition_point.dept = @current_user.primary_dept
    @transition_point.active = true
    unless @transition_point.save
      flash[:danger] = @transition_point.errors.full_messages.join(", ")
      redirect_to new_kapa_main_transition_point_path(:id => @curriculum) and return false
    end
    flash[:success] = "Academic record was successfully created."
    redirect_to kapa_main_transition_point_path(:id => @transition_point)
  end

  def index
    @filter = filter
    @transition_points = Kapa::TransitionPoint.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::TransitionPoint.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "#{@filter.name}_#{Kapa::Term.find(@filter.term_id).description if @filter.term_id.present?}.csv"
  end

end
