module Kapa::KapaModelBase
  extend ActiveSupport::Concern

  included do
    self.abstract_class = true
    self.inheritance_column = nil
    serialize :yml, Hash
    attr_writer :depts
    before_save :serialize_depts
  end

  def serialize_depts
    self.dept = @depts.delete_if {|v| v.blank?}.join(",") if self.has_attribute?(:dept) and @depts
  end

  def deserialize(name, options = {})
    name = name.to_s if self.class.serialize_field.to_s == "json"
    attr_storage = self[self.class.serialize_field]
    if attr_storage.blank? or attr_storage[name].blank?
      value = Hash.new
    else
      value = attr_storage[name]
    end

    options[:as] ? options[:as].new(value) : value.clone
  end

  def serialize(name, value)
    name = name.to_s if self.class.serialize_field.to_s == "json"
    #Serialized attributes are designed to store extra fields like additional file information, so it is OK to bypass strong parameter; 
    #However, it should not be used to store values which change application behaviors. 
    if value.is_a?(ActionController::Parameters)
      value = value.permit!.to_hash
    elsif value.is_a?(Hash)
      value = value.to_h
    end

    self[self.class.serialize_field] ||= Hash.new
    self[self.class.serialize_field][name] = value
  end

  def serialize!(name, value)
    self.serialize(name, value)
    self.save!
  end

  def update_serialized_attributes(name, attributes)
    value = self.deserialize(name)
    #Serialized attributes are designed to store extra fields like additional file information, so it is OK to bypass strong parameter; 
    #However, it should not be used to store values which change application behaviors. 
    if attributes.is_a?(ActionController::Parameters)
      hash = attributes.permit!.to_hash
    else
      hash = attributes.to_h
    end
    hash.each_pair do |k, v|
      value[k.to_sym] = v
    end
    self.serialize(name, value)
  end

  def update_serialized_attributes!(name, attributes)
    self.update_serialized_attributes(name, attributes)
    self.save!
  end

  def rsend(*args, &block)
    value = self
    args.each do |arg|
      #Recursive send will continue unless it gets nil value.
      value = value.__send__(*arg) unless value.nil?
    end
    value
  end

  def attr_desc(name, property_name = name)
    return Kapa::Property.lookup_description(property_name, self.send(name))
  end

  def attr_desc_short(name, property_name = name)
    return Kapa::Property.lookup_description_short(property_name, self.send(name))
  end

  def attr_category(name, property_name = name)
    return Kapa::Property.lookup_category(property_name, self.send(name))
  end

  def ext
    self.deserialize(:_ext, :as => OpenStruct)
  end

  def update_ext(attributes)
    self.update_serialized_attributes(:_ext, attributes) if attributes.present?
  end

  def update_ext!(attributes)
    update_ext(attributes)
    self.save!
  end

  def to_param
    self.class.hashids.encode(id)
  end

  def accessible?(user)
    unless user.check_permission(kapa_model_name, "R")
      return false
    end

    case user.access_scope(kapa_model_name)
      when 30
        return true
      when 20
#        depts = self.dept.is_a?(Array) ? self.dept : [self.dept]
        return (user.depts.any? {|dept| depts.include?(dept)} or self.user_assignments.exists?(:user_id => user.id))
      when 10
        return self.user_assignments.exists?(:user_id => user.id)
      else
        return false
    end
  end

  def kapa_model_name
    self.class.name.tableize.sub("/", "_")
  end

  def depts
    self.dept.to_s.split(/,\s*/)
  end

  def desc_of(attr_name, options = {})
    options[:property] = attr_name if options[:property].nil?
    options[:default] = self.send(attr_name) if options[:default].nil?
    Kapa::Property.lookup_description(options[:property], self.send(attr_name))
  end

  def short_desc_of(attr_name, options = {})
    options[:property] = attr_name if options[:property].nil?
    options[:default] = self.send(attr_name) if options[:default].nil?
    Kapa::Property.lookup_description_short(options[:property], self.send(attr_name))
  end

  def category_of(attr_name, options = {})
    options[:property] = attr_name if options[:property].nil?
    options[:default] = self.send(attr_name) if options[:default].nil?
    Kapa::Property.lookup_category(options[:property], self.send(attr_name))
  end

  class_methods do
    def serialize_field
      if @serialize_field
        @serialize_field 
      else
        :yml
      end  
    end

    def serialize_field=(name)
      @serialize_field = name
    end

    def selections
      [["Not Defined!", "ND"]]
    end

    def encrypt(string)
      public_key = OpenSSL::PKey::RSA.new(File.read(Rails.configuration.public_key))
      return Base64.encode64(public_key.public_encrypt(string))
    end

    def decrypt(string, key)
      unless string.blank?
        private_key = OpenSSL::PKey::RSA.new(key, Rails.configuration.passphrase)
        return private_key.private_decrypt(Base64.decode64(string))
      end
    end

    def column_matches(hash, pattern = "%?%")
      conditions = ["0=1"]
      hash.each_pair do |key, value|
        values = value.is_a?(Array) ? value : [value]
        values = values.delete_if { |v| v.blank? }
        values.each { |v| conditions[0] << " or #{key} like ?" }
        conditions.concat(values.collect { |v| pattern.gsub("?", v.to_s) })
      end
      where(conditions)
    end

    #TODO This uses MySQL specific function and does not work in other platforms
    def column_contains(hash, exception = nil)
      conditions = ["0=1"]
      hash.each_pair do |key, value|
        values = value.is_a?(Array) ? value : [value]
        values = values.delete_if { |v| v.blank? }
        values.each { |v| conditions[0] << " or find_in_set(?, replace(#{key}, ' ', '')) > 0" if v.present? }
        conditions.concat(values)
      end
      conditions[0] << " or #{exception}" if exception
      where(conditions)
    end

    def depts_scope(depts, user_id = nil, extra_exception = nil)
      if user_id
        exception = "user_assignments.user_id = #{user_id}"
        exception << " or #{extra_exception}" if extra_exception
      end
      self.column_contains({"#{self.table_name}.dept" => depts}, exception)
    end

    def assigned_scope(user_id)
      where("user_assignments.user_id" => user_id)
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      objects = self.all
      objects = objects.order(options[:order]) if options[:order].present?
      return objects
    end

    def to_csv(options = {})
      objects = self.search(options)
      format = options[:format] ? options[:format] : self.csv_format
      excluded_keys = options[:exclude] || []
      keys = format.keys.delete_if {|key| excluded_keys.include?(key)}

      CSV.generate do |csv|
        csv << keys
        objects.each do |o|
          csv << keys.collect {|k| o.rsend(*csv_format[k]) }
        end
      end
    end

    def to_table(options = {})
      objects = self.search(options)
      if options[:format]
        format = options[:format]
      else
        #default format to dump all columns   
        format = self.attribute_names.each_with_object({}) {|a, h|  h[a.to_sym] = [a.to_sym]}
      end
      excluded_keys = options[:exclude] || []
      keys = format.keys.delete_if {|key| excluded_keys.include?(key)}

      if options[:as].to_s == "csv"
        CSV.generate do |csv|
          csv << keys
          objects.each do |o|
            csv << keys.collect {|k| 
              value = o.rsend(*format[k])
              if k.to_s == "yml"
                o.yml_before_type_cast
              elsif value.is_a? Array
                value.join(",")
              else
                value
              end
            }
          end
        end
      else
        table = []
        table << keys
        objects.each do |o|
          table << keys.collect {|k| o.rsend(*format[k]) }
        end
        return table
      end
    end

    def find(id)
      if id.is_a?(String) and !id.match(/^[0-9]+$/)
        super(hashids.decode(id).first)
      else
        super(id)
      end
    end

    def find_by_hashid(id)
      find_by_id(hashids.decode(id).first)
    end

    def hashids
      Hashids.new("#{table_name}#{Rails.application.secrets.hashid_salt}", 10)
    end
  end
end
