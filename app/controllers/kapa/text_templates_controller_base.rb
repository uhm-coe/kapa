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
  end

  def update
    @text_template = Kapa::TextTemplate.find(params[:id])
    @text_template.attributes = text_template_params
    @text_template.update_serialized_attributes!(:_ext, params[:text_template_ext]) if params[:text_template_ext].present?

    if @text_template.save
      flash[:notice] = "Text template was successfully updated."
    else
      flash[:alert] = @text_template.errors.full_messages.join(", ")
    end
    redirect_to kapa_text_template_path(:id => @text_template)
  end

  def new
    @text_template = Kapa::TextTemplate.new(:template_path => "/kapa/text_templates/default")
  end

  def create
    @text_template = Kapa::TextTemplate.new
    @text_template.attributes = text_template_params

    unless @text_template.save
      flash[:alert] = @text_template.errors.full_messages.join(", ")
      redirect_to new_kapa_text_template_path and return false
    end
    flash[:notice] = "Text template was successfully created."
    redirect_to kapa_text_template_path(:id => @text_template)
  end

  def destroy
    @text_template = Kapa::TextTemplate.find params[:id]

    unless @text_template.destroy
      flash[:alert] = error_message_for(@text_template)
      redirect_to kapa_text_template_path(:id => @text_template) and return false
    end
    flash[:notice] = "Text template was successfully deleted."
    redirect_to kapa_text_templates_path
  end

  def export
    @filter = filter
    send_data Kapa::TextTemplate.to_table(:as => :csv, :filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "text_templates.csv"
  end

  def preview
    @text_template = Kapa::TextTemplate.find(params[:id])
    logger.debug "*DEBUG* #{@text_template.to_html}"
    send_data @text_template.to_pdf,
              :type => "application/pdf",
              :disposition => "inline",
              :filename => "#{@text_template.title}_preview.pdf"
  end

  def text_template_params
    params.require(:text_template).permit(:type, :title, :body, :active, :template_path, :dept, :depts => [])
  end
end
