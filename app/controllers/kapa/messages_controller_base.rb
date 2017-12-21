module Kapa::MessagesControllerBase
  extend ActiveSupport::Concern

  def show
    @message = Kapa::Message.find(params[:id])
    @message_ext = @message.ext
    @person = @message.person
    @person_ext = @person.ext if @person
  end

  def update
    @message = Kapa::Message.find(params[:id])
    @person = @message.person
    @message.attributes = message_params
    @message.update_serialized_attributes!(:_ext, params[:message_ext]) if params[:message_ext].present?

    if @message.save
      flash[:success] = "Message was successfully updated."
    else
      flash[:danger] = error_message_for(@message)
    end
    redirect_to kapa_message_path(:id => @message)
  end

  def new
    @person = Kapa::Person.find(params[:id])
    @message = @person.messages.build
  end

  def create
    @message = Kapa::Message.new(message_params)
    @message.dept = [@current_user.primary_dept]

    unless @message.save
      flash[:danger] = error_message_for(@message)
      redirect_to(kapa_error_path) and return false
    end

    flash[:success] = "Message was successfully created."
    redirect_to kapa_message_path(:id => @message)
  end

  def destroy
    @message = Kapa::Message.find params[:id]
    unless @message.destroy
      flash[:danger] = error_message_for(@message)
      redirect_to kapa_message_path(:id => @message) and return false
    end
    flash[:success] = "Message was successfully deleted."
    render(:text => "<script>window.onunload = window.opener.location.reload(); close();</script>")
  end

  def index
    @filter = filter
    @messages = Kapa::Message.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::Message.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "messages_#{filter.type}.csv"
  end

  def send_message
    @message = Kapa::Message.find(params[:id])
    @message.send_message!
    redirect_to params[:return_path]
  end

  private
  def message_params
    params.require(:message).permit(:person_id, :attachable_id, :attachable_type, :message_template_id, :name, :subject, :body, :status, :delivered_at, :scheduled_at)
  end
end
