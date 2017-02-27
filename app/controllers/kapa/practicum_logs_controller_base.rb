module Kapa::PracticumLogsControllerBase
  extend ActiveSupport::Concern

  def show
    @practicum_log = Kapa::PracticumLog.find(params[:id])
    @practicum_log_ext = @practicum_log.ext
    @practicum_placement = @practicum_log.practicum_placement
    @person = @practicum_placement.person
    @person_ext = @person.ext
  end

  def update
    @practicum_log = Kapa::PracticumLog.find(params[:id])
    @practicum_log.attributes = practicum_log_params

    if @practicum_log.save
      flash[:success] = "Log was successfully updated."
    else
      flash[:danger] = error_message_for @practicum_log
    end
    redirect_to kapa_practicum_placement_path(:id => @practicum_log.practicum_placement, :anchor => :practicum_logs)
  end

  def new
    @practicum_placement = Kapa::PracticumPlacement.find(params[:practicum_placement_id])
    @practicum_log = @practicum_placement.practicum_logs.build(:log_date => Date.today, :user_id => @current_user.id)
    @person = @practicum_placement.person
  end

  def create
    @practicum_placement = Kapa::PracticumPlacement.find(params[:practicum_placement_id])
    @practicum_log = @practicum_placement.practicum_logs.build(practicum_log_params)

    if @practicum_log.save
      flash[:success] = "Log was successfully created."
    else
      flash[:danger] = error_message_for @practicum_log
    end
    redirect_to kapa_practicum_log_path(:id => @practicum_log)
  end


  def destroy
    @practicum_log = Kapa::PracticumLog.find(params[:id])

    if @practicum_log.destroy
      flash[:success] = "Log was successfully deleted."
    else
      flash[:danger] = error_message_for @practicum_log
    end
    redirect_to kapa_practicum_placement_path(:id => @practicum_log.practicum_placement, :anchor => params[:anchor])
  end

  def export
    @filter = filter
    send_data Kapa::PracticumLog.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "placement_logs_#{Kapa::Term.find(@filter.term_id).description}_#{Date.today}.csv"
  end

  private
  def practicum_log_params
    params.require(:practicum_log).permit(:practicum_placement_id, :log_date, :type, :duration, :frequency, :category, :status, :user_id, :note,  :task => [], :method => [] )
  end
end
