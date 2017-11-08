# Methods added to this helper will be available to all templates in the application.
module Kapa::KapaHelper

  def model_select(object_name, method, options = {}, html_options = {})
    model_class = options[:model_class]
    selections = model_class.selections(options[:model_options])

    object = instance_variable_get("@#{object_name}".delete("[]"))
    if html_options[:multiple] or options[:exclude_current_value]
      current_value = nil
    else
      current_value = object.send("#{method}") if object
    end
    selection = selections.select { |c| c[1].to_s == current_value.to_s }.first
    # If the current value exists in the db but is not in the selections
    # (i.e., because an Property had been deactivated),
    # add it to the selections or else the first selection will be selected by default
    if selection.blank? and current_value.present? and not options[:grouped]
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
      tag << text_field(object_name, method, :value => description.to_s, :size => description.to_s.length + 5, :disabled => true, :class => "form-control #{options[:class]}")
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
    model_select(object_name, method, options, html_options)
  end

  def user_select(object_name, method, options = {}, html_options = {})
    options[:model_class] = Kapa::User
    options[:model_options] = options
    if options[:lock]
      tag = content_tag(:p, @current_user.person.full_name, :class => "form-control-static")
      name = "#{object_name}[#{method}]"
      name << "[]" if html_options[:multiple]
      tag << hidden_field(object_name, method, :value => @current_user.id, :name => name)
    else
      model_select(object_name, method, options, html_options)
    end
  end

  def person_select(object_name, method, options = {}, html_options = {})
    options[:model_class] = Kapa::Person
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def program_select(object_name, method, options = {}, html_options = {})
    options[:model_class] = Kapa::Program
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def text_template_select(object_name, method, options = {}, html_options = {})
    options[:model_class] = Kapa::TextTemplate
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
      options[:include_blank] = true
      options[:selected] = options[:value]
      select(object_name, index, [["Target", "2"], ["Acceptable", "1"], ["Unacceptable", "0"], ["No Evidence", "N"]], options, html_options.merge(:class => "form-control"))
    end
  end

  def history_select(object_name, method, options = {}, html_options = {})
    model_class = options[:model_class]
    model_method = options[:model_method] ? options[:model_method] : method
    conditions = "#{model_method} is not NULL and #{model_method} <> ''"
    selections = model_class.select("distinct #{model_method}").where(conditions).order('1').collect { |l| l[model_method] }
    select(object_name, method, selections, options, html_options)
  end

  def datetime_picker(object_name, method, options = {})
    input_tag = text_field(object_name, method, options)
    icon_tag = content_tag(:span, content_tag(:span, "", :class => "glyphicon glyphicon-calendar"), :class => "input-group-addon")
    content_tag(:div, "#{input_tag} #{icon_tag}".html_safe, :class => "input-group date datetimepicker")
  end

  def date_picker(object_name, method, options = {})
    input_tag = text_field(object_name, method, options)
    icon_tag = content_tag(:span, content_tag(:span, "", :class => "glyphicon glyphicon-calendar"), :class => "input-group-addon")
    content_tag(:div, "#{input_tag} #{icon_tag}".html_safe, :class => "input-group date datepicker")
  end

  def time_picker(object_name, method, options = {})
    input_tag = text_field(object_name, method, options)
    icon_tag = content_tag(:span, content_tag(:span, "", :class => "glyphicon glyphicon-time"), :class => "input-group-addon")
    content_tag(:div, "#{input_tag} #{icon_tag}".html_safe, :class => "input-group date timepicker")
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

  def document_type(document)
     if document.is_a? Kapa::File
      return "File"
     elsif document.is_a? Kapa::Form
      return "Form"
     elsif document.is_a? Kapa::Text
      return "Text Document"
     elsif document.is_a? Kapa::Exam
      return "Test"
     end
  end

  def document_path(document, options = {})
     if document.is_a? Kapa::File
       return kapa_file_path(options.merge(:id => document))
     elsif document.is_a? Kapa::Form
       return kapa_form_path(options.merge(:id => document))
     elsif document.is_a? Kapa::Text
       return kapa_text_path(options.merge(:id => document))
     elsif document.is_a? Kapa::Exam
       return kapa_exam_path(options.merge(:id => document))
     end
  end

  def button_to_link(name = nil, options = nil, html_options = nil, &block)
    options = "javascript:void(0)" if options.nil?
    name = "#{content_tag(:span, "", :class => "glyphicon #{html_options[:icon]}")} #{name}" if html_options[:icon]
    if html_options[:class]
      html_options[:class] = "btn #{html_options[:class]}"
    else
      html_options[:class] = "btn btn-default"
    end
    link_to(name.html_safe, options, html_options, &block)
  end

  def popover_button(name = nil, content = nil, html_options = nil, &block)
    html_options[:tabindex] = "0"
    html_options[:role] = "button"
    html_options["data-content"] = content
    html_options["data-toggle"] = "popover"
    html_options["data-trigger"] = "focus"
    html_options["data-html"] = true
    html_options["data-placement"] = "top" if html_options["data-placement"].nil?
    html_options[:title] = html_options[:title] if html_options[:title]
    button_to_link(name, nil, html_options.merge(:disabled => content.blank?), &block)
  end

  def beta?
    Rails.application.secrets.release != "live"
  end

  private
  def next_id(prefix, index)
    i = @scores.keys.index(index)
    if i == @scores.keys.length - 1
      return "#{prefix}_#{@scores.keys.first}"
    else
      return "#{prefix}_#{@scores.keys[i + 1]}"
    end
  end
end
