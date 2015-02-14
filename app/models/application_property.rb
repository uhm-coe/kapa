class ApplicationProperty < ApplicationBaseModel
  self.table_name = :properties
  @@description_cache = HashWithIndifferentAccess.new
  @@description_detail_cache = HashWithIndifferentAccess.new
  @@category_cache = HashWithIndifferentAccess.new

  validates_uniqueness_of :code, :scope => :name
  validates_presence_of :code

  def self.refresh_cache
    @@description_cache.clear
    ApplicationProperty.find(:all).each {|v| @@description_cache["#{v.name}_#{v.code}"] = v.description}
    @@description_detail_cache.clear
    ApplicationProperty.find(:all).each {|v| @@description_detail_cache["#{v.name}_#{v.code}"] = v.description_short}
    @@category_cache.clear
    ApplicationProperty.find(:all).each {|v| @@category_cache["#{v.name}_#{v.code}"] = v.category}
  end

  def self.selections(options = {})
    filter = ApplicationFilter.new(:name => options[:name].to_s)
    filter.append_condition("active = 1")
    filter.append_condition("name = ?", :name)
    filter.append_depts_condition("dept like ?", options[:depts]) if options[:depts]
    filter.append_availability_condition("code in (?)", options[:program], options[:name]) if options[:program]
    filter.append_condition(options[:conditions]) if options[:conditions]
    selections = []
    ApplicationProperty.find(:all, :conditions => filter.conditions, :order => "sequence DESC, description").each do |v|
      code = v.code
      description = ""
      description << "#{v.code}/" if options[:include_code]
      description << v.description
      selections.push [description, code]
      options[:include_value] = nil if v.code == options[:include_value].to_s
    end
    #This is needed to eliminate a blank field.
    options[:include_value] = nil if options[:include_value] == "" and options[:include_blank]
    #If the current value does not exist in the list, we have to add it manually.
    selections = [[options[:include_value], options[:include_value]]] + selections if options[:include_value]
    return selections
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
    filter = ApplicationFilter.new(:name => name.to_s)
#    filter.append_condition("active = 1")
    filter.append_condition("name = ?", :name)
    filter.append_condition("category = '#{options[:category]}'") if options[:category]
    filter.append_depts_condition("dept like ?", options[:depts]) if options[:depts]
    return ApplicationProperty.find(:all, :conditions => filter.conditions, :order => "sequence DESC, code").collect {|v| v.code}
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
