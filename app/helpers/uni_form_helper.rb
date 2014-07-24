module UniFormHelper

  def uni_form_for(record, options = {}, &proc)
    options[:builder] = UniFormBuilder
    options[:html] = {} if options[:html].blank?
    options[:html][:class] = "uniForm"
    form_for(record, options, &proc)
  end

  def uni_fields_for(record_name, options = {}, &proc)
    options[:builder] = UniFormBuilder
    fields_for(record_name, nil, options, &proc)
  end

  def uni_text_field object_name, method, options = {}
    uni_fields_for object_name do |f|
      f.text_field(method, options)
    end
  end

  def uni_password_field object_name, method, options = {}
    uni_fields_for object_name do |f|
      f.password_field(method, options)
    end
  end

  def uni_text_area object_name, method, options = {}
    object = instance_variable_get("@#{object_name}")
    value = object.send("#{method}") if object
    uni_fields_for object_name do |f|
      f.text_area(method, options.merge(:value => value))
    end
  end

  def uni_check_box object_name, method, options = {}, checked_value = "Y", unchecked_value = "N"
    uni_fields_for object_name do |f|
      f.check_box(method, options, checked_value, unchecked_value)
    end
  end

  def uni_select object_name, method, choices, options = {}, html_options = {}
    uni_fields_for object_name do |f|
      f.select(method, choices, options, html_options)
    end
  end

  def uni_property_select object_name, method, options = {}, html_options = {}
    uni_fields_for object_name do |f|
      f.property_select(method, options, html_options)
    end
  end

  def uni_date_select object_name, method, options = {}
    uni_fields_for object_name do |f|
      f.date_select(method, options)
    end
  end
  
  def uni_radio_button object_name, method, tag_value = "Y", options = {}
    uni_fields_for object_name do |f|
      f.radio_button(method, tag_value, options)
    end
  end

  class UniFormBuilder < ActionView::Helpers::FormBuilder

    def text_field method, options = {}
      tag = super(method, options.merge({:class => "textInput auto  #{options[:class]}"}))
      build_field(tag, method, options)
    end

    def password_field method, options = {}
      tag = super(method, options.merge({:class => "textInput auto  #{options[:class]}"}))
      build_field tag, method, options
    end

    def file_field method, options = {}
      tag = super(method, options.merge({:class => "fileUpload auto  #{options[:class]}"}))
      build_field tag, method, options
    end

    def text_area method, options = {}
      object = @template.instance_variable_get("@#{@object_name}")
      value = object.send("#{method}") if object
      options[:lock] = true
      tag = options[:lock] ? @template.content_tag(:p, value) : super(method, options.merge({:rows => 80, :class => "textArea auto  #{options[:class]}", :value => value}))
      build_field tag, method, options
    end

    def date_select method, options = {}
      tag = @template.date_picker @object_name, method, options.merge(:class => "textInput auto #{options[:class]}")
      build_field tag, method, options
    end

    def select method, choices, options = {}, html_options = {}
      tag = super(method, choices, options, html_options.merge(:class => "select auto #{options[:class]}"))
      build_field tag, method, options
    end

    def property_select method, options = {}, html_options = {}
      tag = @template.property_select(@object_name, method, options, html_options.merge(:class => "select auto #{options[:class]}"))
      build_field tag, method, options
    end

    def model_select method, options = {}, html_options = {}
      tag = @template.model_select(@object_name, method, options, html_options.merge(:class => "select auto #{options[:class]}"))
      build_field tag, method, options
    end
    def check_box method, options = {}, checked_value = "Y", unchecked_value = "N"
      tag = super(method, options, checked_value, unchecked_value)
      build_field tag, method, options.merge(:inline_label => true)
    end

    def radio_button method, tag_value = "Y", options = {}
      tag = super(method, tag_value, options)
      build_field tag, method, options.merge(:inline_label => true)
    end

    private
    def build_field(tag, method, options = {}) 
      if options[:label].kind_of?(Hash)
        label_options = options[:label]
      elsif options[:label].kind_of?(String)
        label_options = {:text => options[:label]}
      else
        label_options = {:text => method.to_s.titleize}
      end

      tags = ""
      if options[:inline_label] #For checkbox and radio button
        tags << @template.content_tag(:label, "#{tag} #{label_options[:text]}".html_safe, :class => label_options[:class], :for => "#{@object_name}_#{method}")
      else
        tags << @template.content_tag(:label, label_options[:text], :class => label_options[:class], :for => "#{@object_name}_#{method}") unless options[:label] == :no
        tags << tag
      end
#      tags << @template.content_tag(:p, options[:hint], :class => "formHint") if options[:hint]
      @template.content_tag :div, tags.html_safe, :class => "ctrlHolder"
    end
  end  
end
