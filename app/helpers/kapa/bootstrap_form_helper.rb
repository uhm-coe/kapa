module Kapa::BootstrapFormHelper
  ALERT_TYPES = [:success, :info, :warning, :danger] unless const_defined?(:ALERT_TYPES)

  def bootstrap_form_for(record, options = {}, &proc)
    options[:builder] = BootstrapFormBuilder
    options[:html] = options[:html].nil? ? {} : options[:html]
    options[:html][:role] = "form"
    form_for(record, options, &proc)
  end

  def bootstrap_fields_for(record_name, options = {}, &proc)
    fields_for(record_name, nil, options.merge(:builder => BootstrapFormBuilder), &proc)
  end

  def bootstrap_flash(options = {})
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = type.to_sym
      type = :success if type == :notice
      type = :danger  if type == :alert
      type = :danger  if type == :error
      next unless ALERT_TYPES.include?(type)

      tag_class = options.extract!(:class)[:class]
      tag_options = {
        class: "alert fade in alert-#{type} #{tag_class}"
      }.merge(options)

      close_button = content_tag(:button, raw("&times;"), type: "button", class: "close", "data-dismiss" => "alert")

      Array(message).each do |msg|
        text = content_tag(:div, close_button + msg, tag_options)
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end

  class BootstrapFormBuilder < ActionView::Helpers::FormBuilder

    def self.build_label_field(name)
      define_method(name) do |method, *args|
        case name.to_s
          when /(field$)|(area$)|(picker$)/
            options = args.first.is_a?(Hash) ? args.first : {}
            tag = @template.send(name, @object_name, method, clean_options(options).merge(:class => "form-control #{options[:class]}"))

          when "select"
            options = args.second.is_a?(Hash) ? args.second : {}
            html_options = args.third.is_a?(Hash) ? args.third : {}
            tag = @template.send(name, @object_name, method, args.first, clean_options(options), html_options.merge(:class => "form-control #{html_options[:class]}"))

          when "model_select", "user_select", "property_select", "program_select", "term_select", "history_select", "person_select", "date_select", "text_template_select"
            options = args.first.is_a?(Hash) ? args.first : {}
            html_options = args.second.is_a?(Hash) ? args.second : {}
            tag = @template.send(name, @object_name, method, clean_options(options), html_options.merge(:class => "form-control #{html_options[:class]}"))

          when "check_box"
            options = args.first.is_a?(Hash) ? args.first : {}
            args[1] = "Y" if args[1].nil?
            args[2] = "N" if args[2].nil?
            tag = @template.send(name, @object_name, method, *args)

          when "radio_button"
            options = args.second.is_a?(Hash) ? args.second : {}
            args[0] = "Y" if args[0].nil?
            tag = @template.send(name, @object_name, method, *args)

          when "static"
            options = args.first.is_a?(Hash) ? args.first : {}
            tag = @template.content_tag(:p, options[:content].to_s.html_safe, :class => "form-control-static #{options[:class]}")
          else
            tag = @template.send(name, @object_name, method, *args)
        end

        if options[:label].kind_of?(Hash)
          label_options = options[:label]
          label_options[:text] = method.to_s.titleize if label_options[:text].blank?
        elsif options[:label].kind_of?(String)
          label_options = {:text => options[:label]}
        else
          label_options = {:text => method.to_s.titleize}
        end

        if options[:label] == :no
          label_tag = ""
        else
          label_class = "control-label"
          label_class << " required" if options[:required] or (html_options and html_options[:required])
          label_class << " #{label_options[:class]}" if label_options[:class]
          label_tag = @template.content_tag(:label, label_options[:text], :class => label_class, :for => "#{@object_name}_#{method}")
        end

        if options[:tooltip]
          label_tag << " #{@template.content_tag(:a, @template.content_tag(:i, nil, :class => "glyphicon glyphicon-info-sign"), "data-toggle" => "tooltip", "data-placement" => "right", :title => options[:tooltip])}".html_safe
        end

        if options[:hint]
          tag << @template.content_tag(:span, options[:hint], :class => "help-block")
        end

        if name =~ /(check_box)|(radio_button)/
          @template.content_tag(:div, "#{tag} #{label_tag}".html_safe)
        else
          if options[:addon]
            @template.content_tag(:div, "#{label_tag} #{@template.content_tag(:div, "#{tag} #{options[:addon]}".html_safe, :class => "input-group")}".html_safe, :class => "form-group")
          else
            @template.content_tag(:div, "#{label_tag}#{tag}".html_safe, :class => "form-group")
          end
        end
      end
    end

    helpers = %w{text_field password_field text_area file_field check_box radio_button select static model_select property_select term_select program_select history_select user_select date_picker datetime_picker time_picker person_select date_select text_template_select}
    helpers.each do |name|
      build_label_field(name)
    end

    private
    def clean_options(options)
      options.select {|key, value| %w{label hint tooltip addon}.exclude?(key.to_s)  }
    end
  end
end
