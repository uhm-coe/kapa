module Kapa::ContentHelper

  def prepare_contents
    @contents_page = url_for(:only_path => true, :overwrite_params => nil)
    @contents = Kapa::Content.contents_for(@contents_page) if @contents.nil?
    @raw_contents = @contents.to_h.values.each_with_object(OpenStruct.new) { |content, o| o[content.region] = content.html } if @raw_contents.nil?
  end

  def c(key, option = {})
    prepare_contents
    if @contents[key].present?
      @contents[key].to_html(@content_vars)
    else
      "Please edit content..."  
    end
  end
    
end
