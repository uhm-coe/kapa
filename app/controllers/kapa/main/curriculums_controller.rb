class Kapa::Main::CurriculumsController < Kapa::Main::BaseController

  def show
    @curriculum = Curriculum.find(params[:id])
    @program = @curriculum.program
    @journey = @curriculum.deserialize(:journey, :as => OpenStruct)
    @transition_points = @curriculum.transition_points
    @person = @curriculum.person
    @person.details(self)
  end

  def update
    @curriculum = Curriculum.find(params[:id])
    @curriculum.attributes=(params[:curriculum])
    @curriculum.update_serialized_attributes(:journey, params[:journey]) if params[:journey].present?

    if(params[:return_uri])
      @program =  @curriculum.program
      @curriculum.major_primary = @program.major
      @curriculum.distribution = @program.distribution
      @curriculum.track = @program.track
    end

    unless @curriculum.save
      flash[:danger] = @curriculum.errors.full_messages.join(", ")
      if params[:transition_point_id]
        redirect_to kapa_main_transition_point_path(:id => params[:transition_point_id]) and return false
      else
        redirect_to kapa_main_curriculum_path(:id => @curriculum) and return false
      end
    end

    flash[:success] = "Academic record was successfully updated."
    if params[:return_uri]
      redirect_to params[:return_uri]
    else
      if params[:transition_point_id]
        redirect_to kapa_main_transition_point_path(:id => params[:transition_point_id])
      else
        redirect_to kapa_main_curriculum_path(:id => @curriculum)
      end
    end
  end

  def new
    @person = Person.find(params[:id])
    @person.details(self)
  end

  def create
    @person = Person.find(params[:id])
    @curriculum = @person.curriculums.build(params[:curriculum])
    @curriculum.set_default_options
    @curriculum.update_serialized_attributes(:journey, :active => "Y")

    unless @curriculum.save
      flash[:danger] = @curriculum.errors.full_messages.join(", ")
      redirect_to new_kapa_main_curriculum_path(:id => @person) and return false
    end
    @curriculum.update_serialized_attributes(:journey, :active => "Y")
    redirect_to kapa_main_curriculum_path(:id => @curriculum)
  end

  def index
    @filter = curriculums_filter
    order = "persons.last_name, persons.first_name"
    @transition_points = TransitionPoint.paginate(:page => params[:page], :per_page => 20, :include => [{:curriculum => [:person, :program]}, :last_transition_action], :conditions => @filter.conditions, :order => order)
  end

  def export
    @filter = curriculums_filter
    order = "persons.last_name, persons.first_name"
    transition_points = TransitionPoint.find(:all, :include => [{:curriculum => [:person, :program, :term]}, :last_transition_action], :conditions => @filter.conditions, :order => order)

    csv_string = CSV.generate do |csv|
      csv << column_names
      transition_points.each do |c|
        csv << row(c)
      end
    end
    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "cohort_#{@filter.term_desc}.csv"
  end

  private
  def curriculums_filter
    f = filter
    f.append_condition "transition_points.term_id = ?", :term_id
    f.append_condition "transition_points.status = ?", :status
    f.append_condition "transition_points.type = ?", :type
    f.append_condition "transition_actions.action in ('1','2')"
    f.append_condition "programs.code = ?", :program
    f.append_condition "curriculums.distribution = ?", :distribution
    f.append_condition "curriculums.major_primary = ?", :major
    f.append_condition "? in (curriculums.user_primary_id, curriculums.user_secondary_id)", :user_id

    if @current_user.access_scope >= 3
      # do nothing
    elsif @current_user.access_scope == 2
      f.append_program_condition("programs.code in (?)", :depts => @current_user.depts)
    elsif @current_user.access_scope == 1
      f.append_condition "#{@current_user.id} in (curriculums.user_primary_id, curriculums.user_secondary_id)"
    else
      f.append_condition "1=2"
    end
    return f
  end

  def column_names
    [:id_number,
     :last_name,
     :first_name,
     :email,
     :email_alt,
     :ssn,
     :ssn_agreement,
     :cur_street,
     :cur_city,
     :cur_state,
     :cur_postal_code,
     :cur_phone,
     :curriculum_id,
     :term_desc,
     :program_desc,
     :track_desc,
     :major_primary_desc,
     :major_secondary_desc,
     :distribution_desc,
     :second_degree]
  end

  def row(c)
    [rsend(c, :curriculum, :person, :id_number),
     rsend(c, :curriculum, :person, :last_name),
     rsend(c, :curriculum, :person, :first_name),
     rsend(c, :curriculum, :person, :email),
     rsend(c, :curriculum, :person, :contact, :email_alt),
     rsend(c, :curriculum, :person, :ssn),
     rsend(c, :curriculum, :person, :ssn_agreement),
     rsend(c, :curriculum, :person, :contact, :cur_street),
     rsend(c, :curriculum, :person, :contact, :cur_city),
     rsend(c, :curriculum, :person, :contact, :cur_state),
     rsend(c, :curriculum, :person, :contact, :cur_postal_code),
     rsend(c, :curriculum, :person, :contact, :cur_phone),
     rsend(c, :curriculum, :id),
     rsend(c, :term, :description),
     rsend(c, :curriculum, :program, :description),
     rsend(c, :curriculum, :track_desc),
     rsend(c, :curriculum, :major_primary_desc),
     rsend(c, :curriculum, :major_secondary_desc),
     rsend(c, :curriculum, :distribution_desc),
     rsend(c, :curriculum, :second_degree)]
  end
end
