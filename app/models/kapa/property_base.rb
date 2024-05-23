module Kapa::PropertyBase
  extend ActiveSupport::Concern

  included do
    self.table_name = :properties
    validates_uniqueness_of :code, :scope => :name
    validates_presence_of :name, :code
  end

  class_methods do
    @@description_cache = ActiveSupport::OrderedHash.new
    @@description_short_cache = ActiveSupport::OrderedHash.new
    @@category_cache = ActiveSupport::OrderedHash.new

    def refresh_cache
      @@description_cache.clear
      Kapa::Property.all.each { |v| @@description_cache["#{v.name}_#{v.code}"] = v.description }
      @@description_short_cache.clear
      Kapa::Property.all.each { |v| @@description_short_cache["#{v.name}_#{v.code}"] = v.description_short }
      @@category_cache.clear
      Kapa::Property.all.each { |v| @@category_cache["#{v.name}_#{v.code}"] = v.category }
    end

    def selections(options = {})
      properties = where(:active => true, :name => options[:name].to_s)
      properties = properties.depts_scope(options[:depts]) if options[:depts].present?
      properties = properties.where(options[:conditions]) if options[:conditions].present?
      value_method = options[:value_method] ? options[:value_method] : :code
      text_method = options[:text_method] ? options[:text_method] : :description
      group_method = options[:group_method] ? options[:group_method] : :category
      order = options[:order] ? options[:order] : "sequence DESC, code, description"

      properties = properties.order(order)
      if options[:grouped]
        grouped_properties = {}
        properties.group_by(&group_method).each do |category, items|
          grouped_properties[category] = items.collect do |v|
            description = ""
            description << "#{v.send(value_method)}/" if options[:include_code] or options[:include_value]
            description << v.send(text_method)
            [description, v.send(value_method)]
          end
        end
        grouped_properties
      else
        properties.collect do |v|
          description = ""
          description << "#{v.send(value_method)}/" if options[:include_code] or options[:include_value]
          description << v.send(text_method)
          [description, v.send(value_method)]
        end
      end
    end

    def lookup_description(name, code, default_value = code)
      refresh_cache if @@description_cache.empty?
      return @@description_cache["#{name}_#{code}"] ||= default_value
    end

    def lookup_description_short(name, code, default_value = code)
      refresh_cache if @@description_short_cache.empty?
      return @@description_short_cache["#{name}_#{code}"] ||= default_value
    end

    def lookup_category(name, code, default_value = code)
      refresh_cache if @@category_cache.empty?
      return @@category_cache["#{name}_#{code}"] ||= default_value
    end

    def keys(name, options={})
      properties = where(:active => true, :name => name)
      properties = properties.depts_scope(options[:depts]) if options[:depts]
      properties = properties.where(options[:conditions]) if options[:conditions]
      return properties.order("sequence DESC, code").collect { |v| v.code }
    end

    def to_a(name, options={})
      properties = where(:active => true, :name => name)
      properties = properties.depts_scope(options[:depts]) if options[:depts]
      properties = properties.where(options[:conditions]) if options[:conditions]
      method = options[:method] ? options[:method] : :code
      return properties.order("sequence DESC, code").collect { |v| v.send(method)}
    end

    def append(name, code, options={})
      options[:description] = code if options[:description].blank?
      property = where(:name => name, :code => code).first_or_create
      property.update(options)
      return property
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      application_properties = Kapa::Property.all.order("name, sequence DESC, code")
      application_properties = application_properties.where("name" => filter.name)  if filter.name.present?
      application_properties = application_properties.where("active" => filter.active) if filter.active.present?
      return application_properties
    end
  end
end
