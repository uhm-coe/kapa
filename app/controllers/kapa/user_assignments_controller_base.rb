module Kapa::UserAssignmentsControllerBase
  extend ActiveSupport::Concern

  def create
    @user_assignment = Kapa::UserAssignment.new(user_assignment_params)

    if @user_assignment.save
      flash[:success] = "Action was successfully created."
    else
      flash[:danger] = error_message_for @@user_assignment
    end
    redirect_to params[:return_path]
  end


  def destroy
    @user_assignment = Kapa::UserAssignment.find(params[:id])

    if @user_assignment.destroy
      flash[:success] = "User assignment was successfully deleted."
    else
      flash[:danger] = error_message_for @user_assignment
    end
    redirect_to params[:return_path]
  end

  private
  def user_assignment_params
    params.require(:user_assignment).permit(:assignable_type, :assignable_id, :user_id, :task, :due_date)
  end
end
