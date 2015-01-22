class Main::TransitionPointsController < Main::BaseController

  def show
    session[:filter_main][:assessment_rubric_id] = nil if session[:filter_main] and request.get?
    @filter = filter

    @transition_point = TransitionPoint.find(params[:id])
    @transition_point_ext = @transition_point.deserialize(:_ext, :as => OpenStruct)
    @curriculum = @transition_point.curriculum
    @program = @curriculum.program
    @programs = Program.where("active = 1")
    @transition_actions = @transition_point.transition_actions
    @person = @curriculum.person
    @person.details(self)
    @curriculums = @person.curriculums

    @assessment_rubrics = @transition_point.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    @table = AssessmentScore.table_for(@assessment_rubric, "TransitionPoint", @transition_point.id)
  end

  def update
    if params[:transition_point]
      @transition_point = TransitionPoint.find(params[:id])
      @transition_point.attributes = params[:transition_point]
      @transition_point.update_serialized_attributes(:_ext, params[:transition_point_ext])

      unless @transition_point.save
        flash[:danger] = @transition_point.errors.full_messages.join(", ")
        redirect_to main_transition_point_path(:id => @transition_point, :focus => params[:focus]) and return false
      end
    end

    if params[:assessment_scores]
      params[:assessment_scores].each_pair do |k, v|
        scorable_id = k.split("_").first
        criterion_id = k.split("_").last
        score = AssessmentScore.find_or_initialize_by_assessment_scorable_type_and_assessment_scorable_id_and_assessment_criterion_id("TransitionPoint", scorable_id, criterion_id)
        score.rating = v
        score.rated_by = @current_user.uid
        unless score.save
          flash[:danger] = "There was an error updating scores. Please try again."
          redirect_to main_transition_point_path(:id => @transition_point, :focus => params[:focus]) and return false
        end
      end
    end

    flash[:success] = "Transition point was successfully updated."
    redirect_to main_transition_point_path(:id => @transition_point, :focus => params[:focus])
  end

  def new
    @curriculum = Curriculum.find(params[:id])
    @person = @curriculum.person
    @person.details(self)
    @curriculums = @person.curriculums
    @transition_point = @curriculum.transition_points.build(:term_id => Term.current_term.id, :curriculum_id => params[:id])
  end

  def create
    @person = Person.find(params[:id])
    @curriculum = @person.curriculums.find(params[:transition_point][:curriculum_id])

    @transition_point = @curriculum.transition_points.build(params[:transition_point])
    @transition_point.dept = @current_user.primary_dept
    @transition_point.active = true
    unless @transition_point.save
      flash[:danger] = @transition_point.errors.full_messages.join(", ")
      redirect_to new_main_transition_point_path(:id => @curriculum) and return false
    end
    flash[:success] = "Academic record was successfully created."
    redirect_to main_transition_point_path(:id => @transition_point)
  end

  def index
    @filter = transition_point_filter
    order = "persons.last_name, persons.first_name"
    @transition_points = TransitionPoint.paginate(:page => params[:page], :per_page => @filter.per_page, :include => [{:curriculum => [:person, :program]}, :last_transition_action], :conditions => @filter.conditions, :order => order)
  end

  def export
    @filter = transition_point_filter
    order = "persons.last_name, persons.first_name"
    transition_points = TransitionPoint.find(:all, :include => [{:curriculum => [:person, :program]}, :last_transition_action], :conditions => @filter.conditions, :order => order)

    csv_string = CSV.generate do |csv|
      csv << column_names
      transition_points.each do |c|
        csv << row(c)
      end
    end
    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "#{@filter.type}_#{@filter.term_desc}.csv"
  end

  private
  def transition_point_filter
    f = filter
    f.append_condition "transition_points.term_id = ?", :term_id
    f.append_condition "transition_points.status = ?", :status
    f.append_condition "transition_points.type = ?", :type
    f.append_condition "programs.code = ?", :program
    f.append_condition "curriculums.distribution = ?", :distribution
    f.append_condition "curriculums.major_primary = ?", :major
    f.append_condition "? in (transition_points.user_primary_id, transition_points.user_secondary_id)", :user_id

    if @current_user.access_scope >= 3
      # do nothing
    elsif @current_user.access_scope == 2
      f.append_program_condition("programs.code in (?)", :depts => @current_user.depts)
    elsif @current_user.access_scope == 1
      f.append_condition "#{@current_user.id} in (transition_points.user_primary_id, transition_points.user_secondary_id)"
    else
      f.append_condition "1=2"
    end

    return f
  end

  def column_names
    [:id_number,
     :last_name,
     :first_name,
     :ethnicity,
     :gender,
     :email,
     :email_alt,
     :ssn,
     :ssn_agreement,
     :cur_street,
     :cur_city,
     :cur_state,
     :cur_postal_code,
     :cur_phone,
     :program_desc,
     :track_desc,
     :major_primary_desc,
     :major_secondary_desc,
     :distribution_desc,
     :location_desc,
     :second_degree,
     :term_desc,
     :category_desc,
     :priority_desc,
     :status_desc,
     :user_primary,
     :user_secondary,
     :action,
     :action_desc,
     :action_date]
  end

  def row(c)
    [rsend(c, :curriculum, :person, :id_number),
     rsend(c, :curriculum, :person, :last_name),
     rsend(c, :curriculum, :person, :first_name),
     rsend(c, :curriculum, :person, :ethnicity),
     rsend(c, :curriculum, :person, :gender),
     rsend(c, :curriculum, :person, :email),
     rsend(c, :curriculum, :person, :contact, :email_alt),
     rsend(c, :curriculum, :person, :ssn),
     rsend(c, :curriculum, :person, :ssn_agreement),
     rsend(c, :curriculum, :person, :contact, :cur_street),
     rsend(c, :curriculum, :person, :contact, :cur_city),
     rsend(c, :curriculum, :person, :contact, :cur_state),
     rsend(c, :curriculum, :person, :contact, :cur_postal_code),
     rsend(c, :curriculum, :person, :contact, :cur_phone),
     rsend(c, :curriculum, :program, :description),
     rsend(c, :curriculum, :track_desc),
     rsend(c, :curriculum, :major_primary_desc),
     rsend(c, :curriculum, :major_secondary_desc),
     rsend(c, :curriculum, :distribution_desc),
     rsend(c, :curriculum, :location_desc),
     rsend(c, :curriculum, :second_degree),
     rsend(c, :term, :description),
     rsend(c, :category_desc),
     rsend(c, :priority_desc),
     rsend(c, :status_desc),
     rsend(c, :user_primary, :person, :full_name),
     rsend(c, :user_secondary, :person, :full_name),
     rsend(c, :last_transition_action, :action),
     rsend(c, :last_transition_action, :action_desc),
     rsend(c, :last_transition_action, :action_date)]
  end
end
