module Kapa::BulkMessagesControllerBase
  extend ActiveSupport::Concern

  def show
    @bulk_message = Kapa::BulkMessage.find(params[:id])
    @bulk_message_ext = @bulk_message.ext
  end

  def update
    @bulk_message = Kapa::BulkMessage.find(params[:id])
    @bulk_message.attributes = bulk_message_params
    @bulk_message.update_serialized_attributes!(:_ext, params[:bulk_message_ext]) if params[:bulk_message_ext].present?

    if @bulk_message.save
      flash[:success] = "Bulk message was successfully updated."
    else
      flash[:danger] = error_message_for(@bulk_message)
    end
    redirect_to kapa_bulk_message_path(:id => @bulk_message)
  end

  def new
  end

  def create
    @bulk_message = Kapa::BulkMessage.new(bulk_message_params)
    @bulk_message.dept = [@current_user.primary_dept]

    unless @bulk_message.save
      flash[:danger] = error_message_for(@bulk_message)
      redirect_to(kapa_error_path) and return false
    end

    flash[:success] = "Bulk message was successfully created."
    redirect_to kapa_bulk_message_path(:id => @bulk_message)
  end

  def destroy
    @bulk_message = Kapa::BulkMessage.find params[:id]
    unless @bulk_message.destroy
      flash[:danger] = error_message_for(@bulk_message)
      redirect_to kapa_bulk_message_path(:id => @bulk_message) and return false
    end
    flash[:success] = "Bulk message was successfully deleted."
    render(:text => "<script>window.onunload = window.opener.location.reload(); close();</script>")
  end

  def index
    @filter = filter
    @bulk_messages = Kapa::BulkMessage.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::BulkMessage.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "bulk_messages_#{filter.type}.csv"
  end

  private
  def bulk_message_params
    params.require(:bulk_message).permit(:attachable_id, :attachable_type, :name, :subject, :body, :status, :note)
  end
end
