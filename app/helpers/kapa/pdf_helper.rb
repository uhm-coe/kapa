# Tags for PDF layouts (Kapa::Pdf). Chrome renders the HTML without a base URL, so stylesheets and
# images are put into the page itself instead of linked.
module Kapa::PdfHelper
  # A <style> with each stylesheet's compiled CSS, e.g. pdf_stylesheet_tag "kapa/kapa", "kapa/pdf".
  def pdf_stylesheet_tag(*sources)
    safe_join(sources.map { |source| content_tag(:style, pdf_asset_source("#{source}.css").html_safe) }, "\n")
  end

  # An <img> with the image as a data: URI, e.g. pdf_image_tag "kapa/left-MAN.png", :width => "200px".
  def pdf_image_tag(source, options = {})
    data = Base64.strict_encode64(pdf_asset_source(source))
    image_tag("data:#{Rack::Mime.mime_type(File.extname(source))};base64,#{data}", options)
  end

  private

  # The asset's contents: compiled on the fly where Sprockets compiles (development, test),
  # otherwise read from the precompiled files (production).
  def pdf_asset_source(path)
    if Rails.application.assets
      asset = Rails.application.assets.find_asset(path) or raise ArgumentError, "PDF asset not found: #{path}"
      asset.source
    else
      manifest = Rails.application.assets_manifest
      digest_path = manifest.assets[path] or raise ArgumentError, "PDF asset not precompiled: #{path}"
      File.binread(File.join(manifest.directory, digest_path))
    end
  end
end
