module Kapa::PracticumLogsControllerBase
  extend ActiveSupport::Concern

  def create
    @practicum_placement = Kapa::PracticumPlacement.find(params[:id])
    @practicum_log = @practicum_placement.practicum_logs.build(create_practicum_log_params)

    if @practicum_log.save
      flash[:success] = "Log was successfully created."
    else
      flash[:danger] = error_message_for @practicum_log
    end
    redirect_to kapa_practicum_placement_path(:id => @practicum_placement, :anchor => params[:anchor], :practicum_log_panel => @practicum_log.id)
  end

  def update
    @practicum_log = Kapa::PracticumLog.find(params[:id])
    @practicum_log.attributes = update_practicum_log_params(@practicum_log.id.to_s)

    if @practicum_log.save
      flash[:success] = "Log was successfully updated."
    else
      flash[:danger] = error_message_for @practicum_log
    end
    redirect_to kapa_practicum_placement_path(:id => @practicum_log.practicum_placement_id, :anchor => params[:anchor], :practicum_log_panel => params[:practicum_log_panel])
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

  private
  def practicum_log_fields
    [:practicum_placement_id, :log_date, :type, :task, :category, :status, :user_id, :note]
  end
  def create_practicum_log_params
    params.require(:practicum_log).permit(*practicum_log_fields)
  end
  def update_practicum_log_params(practicum_log_id)
    params.require(:practicum_log)[practicum_log_id].permit(*practicum_log_fields)
  end
end
