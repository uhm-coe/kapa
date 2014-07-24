module LabelFormHelper

  def label_form_for(record, options = {}, &proc)
    form_for(record, options.merge(:builder => LabelFormBuilder), &proc)
  end

  def label_fields_for(record_name, options = {}, &proc)
    record_name = "#{record_name}[]" if options[:multiple] and !instance_variable_get("@#{record_name}").new_record?
    fields_for(record_name, nil, options.merge(:builder => LabelFormBuilder), &proc)
  end

  class LabelFormBuilder < ActionView::Helpers::FormBuilder

    def self.build_label_field(name)
      define_method(name) do |method, *args|
        case name
          when "select"
            options = args.second.is_a?(Hash) ? args.second : {}
          when "model_select", "user_select", "property_select", "history_select"
            options = args.first.is_a?(Hash) ? args.first : {}
          when "check_box"
            options = args.first.is_a?(Hash) ? args.first : {}
            args[1] = "Y" if args[1].nil?
            args[2] = "N" if args[2].nil?
          when "radio_button"
            options = args.second.is_a?(Hash) ? args.second : {}
            args[0] = "Y" if args[0].nil?
          else
            options = args.last.is_a?(Hash) ? args.last : {}
        end
        tag = @template.send(name, @object_name, method, *args)
#      Rails.logger.debug "----building #{method} #{options.inspect}"

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
          @template.content_tag(:div, "#{label_tag}<br>#{tag}".html_safe)
        end
      end
    end

    helpers = %w{text_field password_field text_area file_field check_box radio_button select model_select property_select history_select user_select hidden_text_area date_select date_picker}
    helpers.each do |name|
      build_label_field(name)
    end
  end
end
