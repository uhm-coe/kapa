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

  # All contents as db/contents files in a zip; unzip it into the app's db/ folder.
  def export
    send_data Kapa::Content.to_zip,
              :type => "application/zip",
              :disposition => "attachment",
              :filename => "contents-#{Date.today.strftime("%Y%m%d")}.zip"
  end

  # Emails preview in the browser with the registry's sample values; PDFs preview as PDF.
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
    params.require(:content).permit(:body, :subject, :active, :template_path, :dept, :depts => [])
  end
end
