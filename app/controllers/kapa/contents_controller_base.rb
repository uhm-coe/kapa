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

  # Text templates are PDF letters or emails (type "email"). When the app registers templates of that
  # type (Kapa::TextTemplate.registry), a new template must be for one of them; emails always need one.
  # Emails use the mail layout, not a layout path.
  def create
    type = params.dig(:text_template, :type).to_s
    registry = Kapa::TextTemplate.registry(type)
    if (type == "email" || registry.any?) && !registry.key?(params.dig(:text_template, :code))
      flash[:alert] = "Please choose which #{type == "email" ? "email" : "letter"} this template is for."
      redirect_to new_kapa_text_template_path and return false
    end

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

  # Emails preview in the browser with the registry's sample values; letters preview as PDF.
  def preview
    @text_template = Kapa::TextTemplate.find(params[:id])
    if @text_template.email?
      sample = @text_template.template_config[:sample] || {}
      subject = ERB::Util.html_escape(@text_template.render_subject(sample))
      html = "<p><strong>Subject:</strong> #{subject}</p><hr>".html_safe + @text_template.to_html(:locals => sample)
      # to_html already applied the template's layout (none for a plain email).
      render :html => html, :layout => false and return
    end
    sample = @text_template.template_config[:sample] || {}
    logger.debug "*DEBUG* #{@text_template.to_html(:locals => sample.dup)}"
    send_data @text_template.to_pdf(:locals => sample.dup),
              :type => "application/pdf",
              :disposition => "inline",
              :filename => @text_template.pdf_file_name(sample) || "#{@text_template.title}_preview.pdf"
  end

  def text_template_params
    params.require(:text_template).permit(:type, :title, :body, :subject, :code, :active, :template_path, :dept, :depts => [])
  end
end
