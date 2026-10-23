# Renders HTML to PDF with headless Chrome: the grover gem, which runs Puppeteer (Node). The app
# installs Puppeteer (yarn add puppeteer) and may set Rails.configuration.grover_options, merged
# over the defaults below (e.g. :executable_path for a system Chrome, :launch_args).
# Layouts should inline their CSS and images (Kapa::PdfHelper): the HTML is rendered without a base
# URL, so links to /assets would not load.
module Kapa::Pdf
  DEFAULT_OPTIONS = {
    :format => "Letter",
    :margin => {:top => "10mm", :bottom => "10mm", :left => "10mm", :right => "10mm"},
    :print_background => true,
    :emulate_media => "screen",  # the screen CSS the letters were designed with (as wkhtmltopdf used)
    :wait_until => "load"        # everything is inline; nothing to wait for on the network
  }.freeze

  def self.from_html(html, options = {})
    app_options = Rails.configuration.respond_to?(:grover_options) ? Rails.configuration.grover_options.to_h : {}
    Grover.new(html.to_s, **DEFAULT_OPTIONS.deep_merge(app_options).deep_merge(options).deep_symbolize_keys).to_pdf
  end
end
