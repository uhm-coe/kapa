class ApplicationProperty < KapaBaseModel
  self.table_name = :properties
  @@description_cache = HashWithIndifferentAccess.new
  @@description_detail_cache = HashWithIndifferentAccess.new
  @@category_cache = HashWithIndifferentAccess.new

  validates_uniqueness_of :code, :scope => :name
  validates_presence_of :name, :code

  def self.refresh_cache
    @@description_cache.clear
    ApplicationProperty.scoped.each { |v| @@description_cache["#{v.name}_#{v.code}"] = v.description }
    @@description_detail_cache.clear
    ApplicationProperty.scoped.each { |v| @@description_detail_cache["#{v.name}_#{v.code}"] = v.description_short }
    @@category_cache.clear
    ApplicationProperty.scoped.each { |v| @@category_cache["#{v.name}_#{v.code}"] = v.category }
  end

  def self.selections(options = {})
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

  def self.lookup_description(name, code, default_value = code)
    refresh_cache if @@description_cache.empty?
    return @@description_cache["#{name}_#{code}"] ||= default_value
  end

  def self.lookup_description_detail(name, code, default_value = code)
    refresh_cache if @@description_detail_cache.empty?
    return @@description_detail_cache["#{name}_#{code}"] ||= default_value
  end

  def self.lookup_category(name, code, default_value = code)
    refresh_cache if @@category_cache.empty?
    return @@category_cache["#{name}_#{code}"] ||= default_value
  end

  def self.keys(name, options={})
    properties = where(:active => true, :name => options[:name].to_s)
    properties = properties.depts_scope(options[:depts]) if options[:depts]
    properties = properties.where(options[:conditions]) if options[:conditions]
    return properties.order("sequence DESC, code").collect { |v| v.code }
  end

  def self.append(name, code, options={})
    options[:description] = code if options[:description].blank?
    property = find_or_create_by_name_and_code(name, code)
    property.update_attributes(options)
    return property
  end

  def self.search(filter, options = {})
    application_properties = ApplicationProperty.scoped
    if filter.name.present?
      # TODO: A workaround until we remove :academic_period from properties entirely.  (Remove this later.)
      #   Without this conversion to "academic_period", an error on admin/properties/index view would be thrown
      #   if no filters are defined, since the default filter in Kapa::Admin::BaseController sets :name to :term_id.
      if filter.name == "term_id".to_sym
        property_name = "academic_period"
      else
        property_name = filter.name
      end
      application_properties = application_properties.where("name" => property_name)
    end
    application_properties = application_properties.where("active" => filter.active) if filter.active.present?
    return application_properties
  end
end
