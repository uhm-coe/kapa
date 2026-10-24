require "open3"

# Renders HTML to PDF with WeasyPrint (pdf_render.py, next to this file), which servers install with
# apt (weasyprint, plus fonts: fonts-urw-base35 for Helvetica, fonts-liberation). Only data: URIs
# are loaded, so layouts inline their CSS and images (Kapa::PdfHelper).
# App settings (optional): Rails.configuration.pdf_options (merged over DEFAULT_OPTIONS),
# pdf_python (default "python3").
module Kapa::Pdf
  class Error < StandardError; end

  RENDER_SCRIPT = File.expand_path("pdf_render.py", __dir__)

  DEFAULT_OPTIONS = {
    :width => 8.5, :height => 11,  # page size in inches (US Letter)
    :margin => 10,                 # page margin in mm
    :zoom => 0.8,                  # the scale WickedPdf (wkhtmltopdf's smart shrinking) printed letters at
    :timeout => 30                 # seconds
  }.freeze

  def self.from_html(html, options = {})
    options = DEFAULT_OPTIONS.merge(Rails.configuration.try(:pdf_options).to_h).merge(options)
    python = Rails.configuration.try(:pdf_python) || "python3"
    args = options.slice(*DEFAULT_OPTIONS.keys).flat_map { |key, value| ["--#{key}", value.to_s] }
    pdf, errors, status = Open3.capture3(python, RENDER_SCRIPT, *args, :stdin_data => html.to_s, :binmode => true)
    raise Error, "PDF rendering failed (#{status}): #{errors.strip.lines.last(5).join}" unless status.success?
    Rails.logger.warn("Kapa::Pdf: #{errors.strip}") if errors.present?
    pdf
  end
end
