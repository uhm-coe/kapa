module Kapa::AdvisingSessionsControllerBase
  extend ActiveSupport::Concern

  def show
    @advising_session = Kapa::AdvisingSession.find(params[:id])
    @person = @advising_session.person
    @curriculums = @person.curriculums
  end

  def new
    @person = Kapa::Person.find(params[:id])

    @curriculums = @person.curriculums
    previous_advising = @person.advising_sessions.order("session_date DESC, id DESC").first
    @advising_session = Kapa::AdvisingSession.new
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
    @advising_session = Kapa::AdvisingSession.new(advising_session_params)
    @advising_session.attributes = advising_session_params
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
    @advising_session = Kapa::AdvisingSession.find(params[:id])
    @advising_session.attributes = advising_session_params

    if @advising_session.save
      flash[:success] = "Advising record was successfully updated."
    else
      flash[:danger] = error_message_for(@advising_session)
    end
    redirect_to kapa_advising_session_path(:id => @advising_session)
  end

  def destroy
    @advising_session = Kapa::AdvisingSession.find(params[:id])
    unless @advising_session.destroy
      flash[:danger] = error_message_for(@advising_session)
      redirect_to kapa_advising_session_path(:id => @advising_session) and return false
    end
    flash[:success] = "Advising record was successfully deleted."
    redirect_to kapa_person_path(:id => @advising_session.person_id)
  end

  def index
    @filter = filter
    @advising_sessions = Kapa::AdvisingSession.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{filter.inspect}"
    send_data Kapa::AdvisingSession.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "advising_history_#{@filter.date_start.to_s}.csv"
  end

  private
  def advising_session_params
    params.require(:advising_session).permit(:session_date, :session_type, :task, :curriculum_id, :interest,
                                             :classification, :location, :user_primary_id, :note, :person_id)
  end
end