module Course::BaseHelper

  def score_select(object_name, index, options = {}, html_options = {})
    if(options[:type] == "text")
      options[:size] = options[:type_option]
      text_field(object_name, index, options)
    elsif(options[:type] == "select")
      options[:name] = options[:type_option]
      options[:include_blank] = true
      options[:selected] = options[:value]
      property_select(object_name, index, options, html_options)
    else
      default_select(object_name, index, options, html_options)
    end
  end

  def default_select(object_name, index, options = {}, html_options = {})
    selection_tag = ""
    [["2", "Target"], ["1", "Acceptable"], ["0", "Unacceptable"], ["N", "No Evidence"], ["Clr", "Clear Entry"]].each do |i|
      selection_tag << content_tag(:div, i[0], :title => i[1], :class => "score_select_item #{score_class(i[0])}")
    end
    tag = content_tag(:div, selection_tag.html_safe, :class => "score_select", :style => "display:none")
    tag << text_field(object_name, index, :size => 1, :value => options[:value], :class => "score_field #{score_class(options[:value])}", :maxlength => 1, :next_id => options[:next_id])
    content_tag(:div, tag.html_safe, :class => "score")
  end

  private
  def default_selections

  end

  def next_id(prefix, index)
    i = @table.keys.index(index)
    if i == @table.keys.length - 1
      return "#{prefix}_#{@table.keys.first}"
    else
      return "#{prefix}_#{@table.keys[i + 1]}"
    end
  end

  def score_class(score)
    case score
    when "2"
      "target"
    when "1"
      "acceptable"
    when "0"
      "unacceptable"
    when "N"
      "no_evidence"
    when "Clr"
      "blank"
    end
  end

end
