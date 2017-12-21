module Kapa::MessageTemplatesControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @message_templates = Kapa::MessageTemplate.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def show
    @message_template = Kapa::MessageTemplate.find(params[:id])
    @message_template_ext = @message_template.ext
    @title = @message_template.title
    render :layout => "/kapa/layouts/document"
  end

  def update
    @message_template = Kapa::MessageTemplate.find(params[:id])
    @message_template.attributes = message_template_params
    @message_template.update_serialized_attributes!(:_ext, params[:message_template_ext]) if params[:message_template_ext].present?

    if @message_template.save
      flash[:success] = "Text template was successfully updated."
    else
      flash[:danger] = @message_template.errors.full_messages.join(", ")
    end
    redirect_to kapa_message_template_path(:id => @message_template)
  end

  def new
    @message_template = Kapa::MessageTemplate.new
  end

  def create
    @message_template = Kapa::MessageTemplate.new
    @message_template.attributes = message_template_params

    unless @message_template.save
      flash[:danger] = @message_template.errors.full_messages.join(", ")
      redirect_to new_kapa_message_template_path and return false
    end
    flash[:success] = "Text template was successfully created."
    redirect_to kapa_message_template_path(:id => @message_template)
  end

  def destroy
    @message_template = Kapa::MessageTemplate.find params[:id]

    unless @message_template.destroy
      flash[:danger] = error_message_for(@message_template)
      redirect_to kapa_message_template_path(:id => @message_template) and return false
    end
    flash[:success] = "Text template was successfully deleted."
    redirect_to kapa_message_templates_path
  end

  def message_template_params
    params.require(:message_template).permit(:type, :title, :body, :active, :dept, :depts => [])
  end
end
