module Kapa::KapaModelBase
  extend ActiveSupport::Concern

  included do
    self.abstract_class = true
    self.inheritance_column = nil
    serialize :yml, Hash
  end

  def deserialize(name, options = {})
    if self.yml.blank? or self.yml[name].blank?
      object = Hash.new
    else
      object = self.yml[name]
    end
    options[:as] ? options[:as].new(object) : object.clone
  end

  def serialize(name, value)
    self.yml = Hash.new if self.yml.blank?
    self.yml[name] = value if value
  end

  def serialize!(name, value)
    self.serialize(name, value)
    self.save!
  end

  def update_serialized_attributes(name, hash)
    value = self.deserialize(name)
    hash.each_pair do |k, v|
      value[k.to_sym] = v
    end if hash.is_a?(Hash)
    self.serialize(name, value)
  end

  def update_serialized_attributes!(name, value)
    self.update_serialized_attributes(name, value)
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

  def ext
    self.deserialize(:_ext, :as => OpenStruct)
  end

  def update_ext(attributes)
    self.update_serialized_attributes(:_ext, attributes) if attributes.present?
  end

  def to_param
    self.class.hashids.encode(id)
  end

  def accessible?(user)
    unless user.check_permission(10, kapa_model_name)
      return false
    end

    case user.access_scope(kapa_model_name)
      when 30
        return true
      when 20
        return (user.dept.any? {|dept| self.dept.include?(dept)} or self.user_assignments.exists?(:user_id => user.id))
      when 10
        return self.user_assignments.exists?(:user_id => user.id)
      else
        return false
    end
  end

  def kapa_model_name
    self.class.name.tableize.sub("/", "_")
  end

  class_methods do
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
      keys = self.csv_format.keys
      CSV.generate do |csv|
        csv << keys
        objects.each do |o|
          csv << keys.collect {|k| o.rsend(*csv_format[k]) }
        end
      end
    end

    def csv_format
      #This method should be implemented in subclasses to define csv data.
      {}
    end

    def find(id)
      if id.is_a?(String) and !id.match(/^[0-9]+$/)
        super(hashids.decode(id).first)
      else
        super(id)
      end
    end

    def hashids
      Hashids.new(table_name, 10)
    end
  end
end
