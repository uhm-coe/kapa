class Advising::SessionsController < Advising::BaseController

  def show
    @advising_session = AdvisingSession.find(params[:id])
    @person = @advising_session.person
    @person.details(self)
    @curriculums = @person.curriculums
  end

  def new
    @person = Person.find(params[:id])
    @person.details(self)
    @curriculums = @person.curriculums
    previous_advising = @person.advising_sessions.find(:first, :order => "session_date DESC, id DESC")
    @advising_session = AdvisingSession.new
    @advising_session.person_id = params[:id]
    @advising_session.user_primary_id = @current_user.id
    @advising_session.session_date = Date.today
    if previous_advising
      @advising_session.curriculum_id = previous_advising.curriculum_id
      @advising_session.classification = previous_advising.classification
      @advising_session.interest = previous_advising.interest
      @advising_session.current_field = previous_advising.current_field
      @advising_session.location = previous_advising.location
    end
  end

  def create
    @advising_session = AdvisingSession.new(params[:advising_session])
    @advising_session.attributes = params[:advising_session]
    @advising_session.dept = @current_user.primary_dept
    @person = @advising_session.person

    unless @advising_session.save
      flash[:danger] = error_message_for(@advising_session)
      redirect_to new_advising_session_path(:id => @person) and return false
    end
    flash[:success] = "Advising record was successfully created."
    redirect_to advising_session_path(:id => @advising_session)
  end

  def update
    @advising_session = AdvisingSession.find(params[:id])
    @advising_session.attributes = params[:advising_session]

    if @advising_session.save
      flash[:success] = "Advising record was successfully updated."
    else
      flash[:danger] = error_message_for(@advising_session)
    end
    redirect_to advising_session_path(:id => @advising_session)
  end

  def destroy
    @advising_session = AdvisingSession.find(params[:id])
    unless @advising_session.destroy
      flash[:danger] = error_message_for(@advising_session)
      redirect_to advising_session_path(:id => @advising_session) and return false
    end
    flash[:success] = "Advising record was successfully deleted."
    redirect_to main_person_path(:id => @advising_session.person_id)
  end

  def index
    @filter = sessions_filter
    @advising_sessions = AdvisingSession.paginate(:page => params[:page], :per_page => 20, :include => :person, :order => "session_date DESC, id DESC", :conditions => @filter.conditions)
  end

  def export
    @filter = sessions_filter
    advisings = AdvisingSession.find(:all, :include => [:person => :contact], :order => "session_date DESC, id DESC", :conditions => @filter.conditions)
    csv_string = CSV.generate do |csv|
      csv << [:id_number,
              :last_name,
              :first_name,
              :cur_street,
              :cur_city,
              :cur_state,
              :cur_postal_code,
              :cur_phone,
              :email,
              :session_date,
              :session_type,
              :task,
              :classification,
              :interest,
              :location,
              :handled_by]
      advisings.each do |c|
        csv << [rsend(c, :person, :id_number),
                rsend(c, :person, :last_name),
                rsend(c, :person, :first_name),
                rsend(c, :person, :contact, :cur_street),
                rsend(c, :person, :contact, :cur_city),
                rsend(c, :person, :contact, :cur_state),
                rsend(c, :person, :contact, :cur_postal_code),
                rsend(c, :person, :contact, :cur_phone),
                rsend(c, :person, :contact, :email),
                rsend(c, :session_date),
                rsend(c, :session_type),
                rsend(c, :task),
                rsend(c, :classification),
                rsend(c, :interest),
                rsend(c, :location),
                rsend(c, :handled_by)]
      end

    end
    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "advising_history #{@filter.date_start.to_s}.csv"
  end

  private
  def sessions_filter
    f = filter
    f.append_condition "handled_by = ?", :handled_by
    f.append_condition "session_date >= ?", :date_start
    f.append_condition "session_date <= ?", :date_end
    f.append_condition "task = ?", :task
    f.append_condition "interest = ?", :interest

    if @current_user.access_scope >= 3
      # do nothing
    elsif @current_user.access_scope == 2
      f.append_depts_condition("dept like ?", @current_user.depts) unless @current_user.manage? :advising
    elsif @current_user.access_scope == 1
      f.append_condition "#{@current_user.id} in (advising_sessions.user_primary_id, advising_sessions.user_secondary_id)"
    else
      f.append_condition "1=2"
    end

    return f
  end
end
