module Kapa::PropertyBase
  extend ActiveSupport::Concern

  included do
    self.table_name = :properties
    validates_uniqueness_of :code, :scope => :name
    validates_presence_of :name, :code
  end

  class_methods do
    @@description_cache = ActiveSupport::OrderedHash.new
    @@description_detail_cache = ActiveSupport::OrderedHash.new
    @@category_cache = ActiveSupport::OrderedHash.new

    def refresh_cache
      @@description_cache.clear
      Kapa::Property.all.each { |v| @@description_cache["#{v.name}_#{v.code}"] = v.description }
      @@description_detail_cache.clear
      Kapa::Property.all.each { |v| @@description_detail_cache["#{v.name}_#{v.code}"] = v.description_short }
      @@category_cache.clear
      Kapa::Property.all.each { |v| @@category_cache["#{v.name}_#{v.code}"] = v.category }
    end

    def selections(options = {})
      properties = where(:active => true, :name => options[:name].to_s)
      properties = properties.depts_scope(options[:depts]) if options[:depts]
      properties = properties.where(options[:conditions]) if options[:conditions]
      properties.order("sequence DESC, description").collect do |v|
        description = ""
        description << "#{v.code}/" if options[:include_code]
        description << v.description
        [description, v.code]
      end
    end

    def lookup_description(name, code, default_value = code)
      refresh_cache if @@description_cache.empty?
      return @@description_cache["#{name}_#{code}"] ||= default_value
    end

    def lookup_description_detail(name, code, default_value = code)
      refresh_cache if @@description_detail_cache.empty?
      return @@description_detail_cache["#{name}_#{code}"] ||= default_value
    end

    def lookup_category(name, code, default_value = code)
      refresh_cache if @@category_cache.empty?
      return @@category_cache["#{name}_#{code}"] ||= default_value
    end

    def keys(name, options={})
      properties = where(:active => true, :name => options[:name].to_s)
      properties = properties.depts_scope(options[:depts]) if options[:depts]
      properties = properties.where(options[:conditions]) if options[:conditions]
      return properties.order("sequence DESC, code").collect { |v| v.code }
    end

    def append(name, code, options={})
      options[:description] = code if options[:description].blank?
      property = find_or_create_by_name_and_code(name, code)
      property.update_attributes(options)
      return property
    end

    def search(filter, options = {})
      application_properties = Kapa::Property.all
      application_properties = application_properties.where("name" => filter.name)  if filter.name.present?
      application_properties = application_properties.where("active" => filter.active) if filter.active.present?
      return application_properties
    end
  end
end
