module BootstrapFormHelper

  def bootstrap_form_for(record, options = {}, &proc)
    options[:builder] = BootstrapFormBuilder
    options[:html] = options[:html].nil? ? {} : options[:html]
    options[:html][:role] = "form"
    form_for(record, options, &proc)
  end

  def bootstrap_fields_for(record_name, options = {}, &proc)
    fields_for(record_name, nil, options.merge(:builder => BootstrapFormBuilder), &proc)
  end

  class BootstrapFormBuilder < ActionView::Helpers::FormBuilder

    def self.build_label_field(name)
      define_method(name) do |method, *args|
        case name.to_s
          when /(field$)|(area$)/
            options = args.first.is_a?(Hash) ? args.first : {}
            tag = @template.send(name, @object_name, method, options.merge(:class => "form-control"))

          when "select"
            Rails.logger.debug "--select #{args.inspect}"
            options = args.second.is_a?(Hash) ? args.second : {}
            html_options = args.third.is_a?(Hash) ? args.third : {}
            tag = @template.send(name, @object_name, method, args.first, options, html_options.merge(:class => "form-control"))

          when "model_select", "user_select", "property_select", "history_select", "date_select"
            options = args.first.is_a?(Hash) ? args.first : {}
            html_options = args.second.is_a?(Hash) ? args.second : {}
            tag = @template.send(name, @object_name, method, options, html_options.merge(:class => "form-control"))

          when "date_select"
            options = args.first.is_a?(Hash) ? args.first : {}
            html_options = args.second.is_a?(Hash) ? args.second : {}
            tag = @template.send(name, @object_name, method, options, html_options.merge(:class => "form-control date-select"))

          when "check_box"
            options = args.first.is_a?(Hash) ? args.first : {}
            args[1] = "Y" if args[1].nil?
            args[2] = "N" if args[2].nil?
            tag = @template.send(name, @object_name, method, *args)

          when "radio_button"
            options = args.second.is_a?(Hash) ? args.second : {}
            args[0] = "Y" if args[0].nil?
            tag = @template.send(name, @object_name, method, *args)

          else
            tag = @template.send(name, @object_name, method, *args)
        end



        if options[:label].kind_of?(Hash)
          label_options = options[:label]
        elsif options[:label].kind_of?(String)
          label_options = {:text => options[:label]}
        else
          label_options = {:text => method.to_s.titleize}
        end

        if options[:label] == :no
          label_tag = ""
        else
          label_tag = @template.content_tag(:label, label_options[:text], :class => label_options[:class], :for => "#{@object_name}_#{method}")
        end

        if name =~ /(check_box)|(radio_button)/
          @template.content_tag(:div, "#{tag} #{label_tag}".html_safe)
        else
          @template.content_tag(:div, "#{label_tag}#{tag}".html_safe, :class => "form-group")
        end
      end
    end

    helpers = %w{text_field password_field text_area file_field check_box radio_button select model_select property_select history_select user_select hidden_text_area date_select}
    helpers.each do |name|
      build_label_field(name)
    end
  end
end
