class Kapa::Advising::SessionsController < Kapa::Advising::BaseController

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
      redirect_to new_kapa_advising_session_path(:id => @person) and return false
    end
    flash[:success] = "Advising record was successfully created."
    redirect_to kapa_advising_session_path(:id => @advising_session)
  end

  def update
    @advising_session = AdvisingSession.find(params[:id])
    @advising_session.attributes = params[:advising_session]

    if @advising_session.save
      flash[:success] = "Advising record was successfully updated."
    else
      flash[:danger] = error_message_for(@advising_session)
    end
    redirect_to kapa_advising_session_path(:id => @advising_session)
  end

  def destroy
    @advising_session = AdvisingSession.find(params[:id])
    unless @advising_session.destroy
      flash[:danger] = error_message_for(@advising_session)
      redirect_to kapa_advising_session_path(:id => @advising_session) and return false
    end
    flash[:success] = "Advising record was successfully deleted."
    redirect_to kapa_main_person_path(:id => @advising_session.person_id)
  end

  def index
    @filter = filter
    @advising_sessions = AdvisingSession.search(@filter).order("session_date DESC, advising_sessions.id DESC").paginate(:page => params[:page])
  end

  def export
    @filter = filter
    logger.debug "----filter: #{filter.inspect}"
    send_data AdvisingSession.to_csv(@filter),
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "advising_history_#{@filter.date_start.to_s}.csv"
  end

end
