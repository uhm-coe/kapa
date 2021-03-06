module Kapa::UserAssignmentsControllerBase
  extend ActiveSupport::Concern

  def show
    @user_assignment = Kapa::UserAssignment.find(params[:id])
    @user_assignment_ext = @user_assignment.ext
  end

  def update
    @user_assignment = Kapa::UserAssignment.find(params[:id])
    @user_assignment.attributes = user_assignment_params
    @user_assignment.update_serialized_attributes!(:_ext, params[:user_assignment_ext]) if params[:user_assignment_ext].present?

    if @user_assignment.save
      flash[:notice] = "Assignment was successfully created."
    else
      flash[:alert] = error_message_for @@user_assignment
    end
    redirect_to params[:return_path]
  end

  def new
    @user_assignment = Kapa::UserAssignment.new(:assignable_id => params[:assignable_id], :assignable_type => params[:assignable_type])
  end

  def create
    @user_assignment = Kapa::UserAssignment.new(user_assignment_params)

    if @user_assignment.save
      flash[:notice] = "Assignment was successfully created."
    else
      flash[:alert] = error_message_for @@user_assignment
    end
    redirect_to params[:return_path]
  end

  def destroy
    @user_assignment = Kapa::UserAssignment.find(params[:id])

    if @user_assignment.destroy
      flash[:notice] = "User assignment was successfully deleted."
    else
      flash[:alert] = error_message_for @user_assignment
    end
    redirect_to params[:return_path]
  end

  private
  def user_assignment_params
    params.require(:user_assignment).permit(:assignable_type, :assignable_id, :user_id, :task, :due_at)
  end
end
