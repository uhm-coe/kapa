module Kapa::KapaHelper

  def model_select(object_name, method, options = {}, html_options = {})
    model_class = options[:model_class]
    selections = model_class.selections(options[:model_options])

    if options[:selected]
      current_value = options[:selected]
    elsif html_options[:multiple] or options[:exclude_current_value]
      current_value = nil
      #do not change options[:selected]
    else
      object = instance_variable_get("@#{object_name}".delete("[]"))
      current_value = object.send("#{method}") if object
      options[:selected] = current_value if current_value.present?
    end

    if not options[:grouped]
      selection = selections.select { |c| c[1].to_s == current_value.to_s }.first
      # If the current value exists in the db but is not in the selections because of deactivated properties
      # add it to the selections so that the value will apear in the selection (description will not be displayed)
      if selection.blank? and current_value.present?
        selections.push([current_value, current_value])
      end
    end  

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

  def text_template_select(object_name, method, options = {}, html_options = {})
    options[:model_class] = Kapa::TextTemplate
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def history_select(object_name, method, options = {}, html_options = {})
    model_class = options[:model_class]
    model_method = options[:model_method] ? options[:model_method] : method
    conditions = "#{model_method} is not NULL and #{model_method} <> ''"
    selections = model_class.select("distinct #{model_method}").where(conditions).order('1').collect { |l| l[model_method] }
    select(object_name, method, selections, options, html_options)
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
      return "Letter"
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

end
