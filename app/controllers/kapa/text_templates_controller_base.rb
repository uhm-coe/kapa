module Kapa::TextTemplatesControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @text_templates = Kapa::TextTemplate.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def show
    @text_template = Kapa::TextTemplate.find(params[:id])
    @text_template_ext = @text_template.ext
    @title = @text_template.title
    render :layout => "/kapa/layouts/document"
  end

  def update
    @text_template = Kapa::TextTemplate.find(params[:id])
    @text_template.attributes = text_template_params
    @text_template.update_serialized_attributes!(:_ext, params[:text_template_ext]) if params[:text_template_ext].present?

    if @text_template.save
      flash[:success] = "Text template was successfully updated."
    else
      flash[:danger] = @text_template.errors.full_messages.join(", ")
    end
    redirect_to kapa_text_template_path(:id => @text_template)
  end

  def new
    @text_template = Kapa::TextTemplate.new
  end

  def create
    @text_template = Kapa::TextTemplate.new
    @text_template.attributes = text_template_params

    unless @text_template.save
      flash[:danger] = @text_template.errors.full_messages.join(", ")
      redirect_to new_kapa_text_template_path and return false
    end
    flash[:success] = "Text template was successfully created."
    redirect_to kapa_text_template_path(:id => @text_template)
  end

  def destroy
    @text_template = Kapa::TextTemplate.find params[:id]

    unless @text_template.destroy
      flash[:danger] = error_message_for(@text_template)
      redirect_to kapa_text_template_path(:id => @text_template) and return false
    end
    flash[:success] = "Text template was successfully deleted."
    redirect_to kapa_text_templates_path
  end

  def text_template_params
    params.require(:text_template).permit(:type, :title, :body, :active)
  end
end
