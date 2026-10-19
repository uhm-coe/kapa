module Kapa::ContentsControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @contents = Kapa::Content.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def show
    @content = Kapa::Content.find(params[:id])
    @content_ext = @content.ext
    @title = @content.title
  end

  def update
    @content = Kapa::Content.find(params[:id])
    @content.attributes = content_params
    @content.update_serialized_attributes!(:_ext, params[:content_ext]) if params[:content_ext].present?

    if @content.save
      flash[:notice] = "Template was successfully updated."
    else
      flash[:alert] = @content.errors.full_messages.join(", ")
    end
    redirect_to kapa_content_path(:id => @content)
  end

  def new
    @content = Kapa::Content.new(:template_path => "/kapa/contents/default")
  end

  # Templates are PDF letters or emails (type "email"). When the app registers templates of that
  # type (Kapa::Content.registry), a new template must be for one of them; emails always need one.
  # Emails use the mail layout, not a layout path.
  def create
    type = params.dig(:content, :type).to_s
    registry = Kapa::Content.registry(type)
    if (type == "email" || registry.any?) && !registry.key?(params.dig(:content, :code))
      flash[:alert] = "Please choose which #{type == "email" ? "email" : "letter"} this template is for."
      redirect_to new_kapa_content_path and return false
    end

    @content = Kapa::Content.new
    @content.attributes = content_params

    unless @content.save
      flash[:alert] = @content.errors.full_messages.join(", ")
      redirect_to new_kapa_content_path and return false
    end
    flash[:notice] = "Template was successfully created."
    redirect_to kapa_content_path(:id => @content)
  end

  def destroy
    @content = Kapa::Content.find params[:id]

    unless @content.destroy
      flash[:alert] = error_message_for(@content)
      redirect_to kapa_content_path(:id => @content) and return false
    end
    flash[:notice] = "Template was successfully deleted."
    redirect_to kapa_contents_path
  end

  def export
    @filter = filter
    send_data Kapa::Content.to_table(:as => :csv, :filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "contents.csv"
  end

  # Emails preview in the browser with the registry's sample values; letters preview as PDF.
  def preview
    @content = Kapa::Content.find(params[:id])
    if @content.email?
      sample = @content.template_config[:sample] || {}
      subject = ERB::Util.html_escape(@content.render_subject(sample))
      html = "<p><strong>Subject:</strong> #{subject}</p><hr>".html_safe + @content.to_html(:locals => sample)
      # to_html already applied the template's layout (none for a plain email).
      render :html => html, :layout => false and return
    end
    sample = @content.template_config[:sample] || {}
    logger.debug "*DEBUG* #{@content.to_html(:locals => sample.dup)}"
    send_data @content.to_pdf(:locals => sample.dup),
              :type => "application/pdf",
              :disposition => "inline",
              :filename => @content.pdf_file_name(sample) || "#{@content.title}_preview.pdf"
  end

  def content_params
    params.require(:content).permit(:type, :title, :body, :subject, :code, :active, :template_path, :dept, :depts => [])
  end
end
