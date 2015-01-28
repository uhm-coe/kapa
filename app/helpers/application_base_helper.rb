# Methods added to this helper will be available to all templates in the application.
module ApplicationBaseHelper

  def model_select(object_name, method, options = {}, html_options = {})
    model_name = options[:model_name] ? options[:model_name].to_s : object_name.to_s
    object = instance_variable_get("@#{object_name}".delete("[]"))
    current_value = object.send("#{method}") if object
    options[:selected] = current_value if options[:selected].blank? and current_value.present?
#    options[:include_current] = true if options[:include_current].nil?
    options[:model_options] = {} if options[:model_options].nil?
#    name = options[:name] ||= method
    if html_options[:multiple]
      html_options[:name] = "#{object_name}[#{method}][]"
      html_options[:class] = "kapa-multiselect"
      options[:selected] = options[:selected].split(/,\s*/) if options[:selected].present? and options[:selected].is_a? (String)
    end
    current_value = nil if current_value.blank? or html_options[:multiple] or options[:exclude_current_value]
    choices = model_name.to_s.classify.constantize.selections(options[:model_options].merge(:include_value => current_value))

    if options[:locked]
      choice = choices.select {|c| c[1] == current_value}.first
      description =  choice[0] if choice
      tag = hidden_field(object_name, method, :value => current_value)
      tag << text_field(object_name, method, :value => description.to_s, :size => description.to_s.length + 5, :disabled => true)
      return tag.html_safe
    end

    select(object_name, method, choices , options, html_options)
  end

  def property_select(object_name, method, options = {}, html_options = {})
    options[:name] ||= method
    options[:model_name] = :application_property
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def term_select(object_name, method, options = {}, html_options = {})
    options[:name] ||= method
    options[:model_name] = :term
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def user_select(object_name, method, options = {}, html_options = {})
    options[:model_name] = :user
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def program_select(object_name, method, options = {}, html_options = {})
    options[:model_name] = :program
    options[:model_options] = options
    model_select(object_name, method, options, html_options)
  end

  def score_select(object_name, index, options = {}, html_options = {})
    if(options[:type] == "text")
      options[:size] = options[:type_option]
      text_field(object_name, index, options)
    elsif(options[:type] == "select")
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

  def hidden_text_area(object_name, method, options = {})
    object = instance_variable_get("@#{object_name}".delete("[]"))
    current_value = object.send("#{method}") if object
    text = current_value.blank? ? "Add notes..." : current_value

    tags = link_to_function(text, nil)
    tags << content_tag(:div, text_area(object_name, method, options), :style => "display:none;")
    content_tag(:div, tags.html_safe, :class => "hidden-text-area", :style => options[:style])
  end

  def history_select(object_name, method, options = {}, html_options = {})
    model_name = options[:model_name] ? options[:model_name].to_s : object_name.to_s
    model_method = options[:model_method] ? options[:model_method] : method
    conditions = "#{model_method} is not NULL and #{model_method} <> ''"
    selections = model_name.to_s.classify.constantize.find(:all,
                                                           :select => "distinct #{model_method}",
                                                           :conditions => conditions,
                                                           :order => '1').collect {|l| l[model_method]}
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

  def mail_to_support(name, options = {})
    subject = "SIS Support Request"
    body = "---\n"
    body << "User: #{session[:user_uid]}\n"
    body << "Time: #{format_datetime Time.now}\n"
    body << "Client: #{request.env['HTTP_USER_AGENT'].downcase}\n"
    body << "Network Address: #{request.remote_ip}\n"
    mail_to(Rails.configuration.mail_from, name, :subject => subject, :body => body)
  end

  def controls(&block)
    tag = "<br>"
    tag << submit_tag("Save", class: "btn btn-default")
    tag << " "
    tag << button_to_reset("Reset", class: "btn btn-default")
    tag << capture(&block) if block_given?
    content_tag(:p, tag.html_safe, :class => "center")
  end

  def link_to_id_number(person, options = {:width => 12, :height => 12})
    if person.verified?
      tags = link_to_function(image_tag("/images/icons/star.png", options), nil, {:class => "person_id_button", :data_id_number => person.id_number})
      tags << person.id_number unless options[:icon_only]
      return tags.html_safe
    end
  end

  def button_to_redirect(name, url, options = {})
    logger.debug "-----btr:#{options.inspect}"
    button_to_function(name, nil, options.merge(:class => "redirect btn btn-default", "data-url" => url_for(url)))
  end

  def button_to_reset(value = "Reset", options = {})
    submit_tag(value, options.merge(:type => :reset))
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

  def render_partial(name)
    path = Rails.root.join("app", "views", module_name, "_#{name}.html.erb")
    render :partial => "/kapa/#{module_name}/#{name}" if FileTest.exists?(path)
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

  def render_content(key)
    content = Content.find_by_key(key)
    if content
      content.value.html_safe
    else
      "Undefined!"
    end
  end

  def id_for_multiple(object_name, method)
    object = instance_variable_get("@#{object_name}")
    if object.nil? or object.new_record?
      "#{object_name}_#{method}"
    else
      "#{object_name}_#{object.id}_#{method}"
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

  #def isAccesible?(object)
  #  if object.is_a? Curriculum or object.is_a? TransitionPoint
  #    access_scope = @current_user.access_scope(:main)
  #    if access_scope >= 3
  #      return true
  #    elsif access_scope == 2
  #      #not implemented yet
  #      return true
  #    elsif access_scope == 1
  #      return object.user_primary_id == @current_user.id || object.user_secondary_id == @current_user.id
  #    else
  #      return false
  #    end
  #
  #  elsif object.is_a? AdvisingSession
  #    access_scope = @current_user.access_scope(:advising)
  #    if @current_user.access_scope(:advising) >= 3
  #      return true
  #    elsif access_scope == 2
  #      return self.depts.include?(object.dept)
  #    elsif access_scope == 1
  #      return object.user_primary_id == @current_user.id || object.user_secondary_id == @current_user.id
  #    else
  #      return false
  #    end
  #
  #  elsif object.is_a? Course
  #    access_scope = @current_user.access_scope(:course)
  #    if access_scope >= 3
  #      return true
  #    elsif access_scope == 2
  #      #not implemented yet
  #      return true
  #    elsif access_scope == 1
  #      #not implemented yet
  #      return false
  #    else
  #      return false
  #    end
  #
  #  elsif object.is_a? PracticumPlacement
  #    access_scope = @current_user.access_scope(:practicum)
  #    if access_scope >= 3
  #      return true
  #    elsif access_scope == 2
  #      #not implemented yet
  #      return true
  #    elsif @access_scope == 1
  #      return object.user_primary_id == @current_user.id || object.user_secondary_id == @current_user.id
  #    else
  #      return false
  #    end
  #
  #  else
  #    return false
  #
  #  end
  #end

end
