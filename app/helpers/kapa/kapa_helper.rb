# Methods added to this helper will be available to all templates in the application.
module Kapa::KapaHelper

  def model_select(object_name, method, options = {}, html_options = {})
    model_class = options[:model_class]
    selections = model_class.selections(options[:model_options])

    object = instance_variable_get("@#{object_name}".delete("[]"))
    current_value = object.send("#{method}") if object
    current_value = nil if current_value.blank? or html_options[:multiple] or options[:exclude_current_value]
    selection = selections.select { |c| c[1].to_s == current_value.to_s }.first
    # If the current value exists in the db but is not in the selections
    #   (i.e., because an ApplicationProperty had been deactivated),
    #   add it to the selections or else the first selection will be selected by default
    if selection.blank? and current_value.present?
      selections.push([current_value, current_value])
    end

    if options[:selected].blank? and current_value.present?
      options[:selected] = current_value
    end

    #if html_options[:multiple]
    #  html_options[:name] = "#{object_name}[#{method}][]"
    #  html_options[:class] = "kapa-multiselect"
    #  options[:selected] = options[:selected].split(/,\s*/) if options[:selected].present? and options[:selected].is_a? (String)
    #end

    if options[:locked]
      if selection
        description = selection[0]
      else
        description = current_value
      end
      tag = hidden_field(object_name, method, :value => current_value)
      tag << text_field(object_name, method, :value => description.to_s, :size => description.to_s.length + 5, :disabled => true)
      return tag.html_safe
    end

    select(object_name, method, selections, options, html_options)
  end

  def property_select(object_name, method, options = {}, html_options = {})
    options[:name] ||= method
    options[:model_class] = Kapa::Property
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def term_select(object_name, method, options = {}, html_options = {})
    options[:name] ||= method
    options[:model_class] = Kapa::Term
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def user_select(object_name, method, options = {}, html_options = {})
    options[:model_class] = Kapa::User
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def program_select(object_name, method, options = {}, html_options = {})
    options[:model_class] = Kapa::Program
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def score_select(object_name, index, options = {}, html_options = {})
    if (options[:type] == "text")
      options[:size] = options[:type_option]
      text_field(object_name, index, options)
    elsif (options[:type] == "select")
      options[:name] = options[:type_option]
      options[:include_blank] = true
      options[:selected] = options[:value]
      property_select(object_name, index, options, html_options.merge(:class => "form-control"))
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

  def history_select(object_name, method, options = {}, html_options = {})
    model_class = options[:model_class]
    model_method = options[:model_method] ? options[:model_method] : method
    conditions = "#{model_method} is not NULL and #{model_method} <> ''"
    selections = model_class.select("distinct #{model_method}").where(conditions).order('1').collect { |l| l[model_method] }
    select(object_name, method, selections, options, html_options)
  end

  def date_picker(object_name, method, options = {})
    object = instance_variable_get("@#{object_name}".delete("[]"))
    options[:class] = "kapa-datepicker form-control #{options[:class]}"
    options[:size] = nil
    options[:readonly] = true
    options["data-provide"] = "datepicker"
    options[:id] = "#{object_name}_#{method}"
    options[:id] << "_#{object.object_id}" if object
    text_field(object_name, method, options)
  end

  def format_date(date)
    if date.kind_of? Date or date.kind_of? Time
      date.strftime("%m/%d/%Y")
    else
      date
    end
  end

  def format_datetime(datetime)
    if datetime.kind_of? Time
      datetime.strftime("%m/%d/%Y %H:%M:%S")
    else
      datetime
    end
  end

  def abbr(string, abbr_option = 20)
    str = string.to_s
    if abbr_option.kind_of? Integer
      max_length = abbr_option
      if str.to_s.length > max_length
        abbr_str = str.slice(0..max_length - 1) + "..."
      else
        abbr_str = str
      end
    else
      abbr_str = abbr_option
    end

    content_tag :abbr, abbr_str, :title => str, "data-toggle" => "tooltip", "data-placement" => "right"
  end

  def document_icon(document)
     if document.is_a? Kapa::File
      return "File"
     elsif document.is_a? Kapa::Form
      return "Form"
     elsif document.is_a? Kapa::Exam
      return "Test"
     end
  end

  def document_path(document)
     if document.is_a? Kapa::File
      return kapa_document_file_path(:id => document)
     elsif document.is_a? Kapa::Form
      return kapa_document_form_path(:id => document)
     elsif document.is_a? Kapa::Exam
      return kapa_document_exam_path(:id => document)
     end
  end

  private
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
