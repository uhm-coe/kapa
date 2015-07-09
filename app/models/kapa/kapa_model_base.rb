module Kapa::KapaModelBase
  extend ActiveSupport::Concern

  included do
    self.abstract_class = true
    serialize :yml, Hash
  end # included

  def update_xml
    self.xml = self.yml.to_xml if self.yml.present?
  end

  def deserialize(name, options = {})
    if self.yml.blank? or self.yml[name].blank?
      obj = Hash.new
    else
      obj = self.yml[name]
    end
    options[:as] ? options[:as].new(obj) : obj.clone
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
    obj = self
    args.each do |a|
      b = (a.is_a?(Array) && a.last.is_a?(Proc) ? a.pop : block)
      obj = obj.__send__(*a, &b) if obj
    end
    obj
  end

  def ext
    self.deserialize(:_ext, :as => OpenStruct)
  end

  def to_end_of_day(value)
    DateTime.new(value.year, value.month, value.day, 23, 59, 0, 0) if value.is_a? Date
  end

  # Fix for removing extra blank values and the "multiselect-all" text in multiselect fields
  def remove_values(array)
    array.delete_if { |x| x.blank? || x == "multiselect-all" } if array
  end

  module ClassMethods
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
        conditions.concat(values.collect { |v| pattern.gsub("?", v) })
      end
      where(conditions)
    end

    #TODO This uses MySQL specific function and does not work in other platforms
    def column_contains(hash, exception = nil)
      conditions = ["0=1"]
      hash.each_pair do |key, value|
        values = value.is_a?(Array) ? value : [value]
        values = values.delete_if { |v| v.blank? }
        values.each { |v| conditions[0] << " or find_in_set(?, #{key}) > 0" if v.present? }
        conditions.concat(values)
      end
      conditions[0] << " or #{exception}" if exception
      where(conditions)
    end

    def depts_scope(depts, exception = nil)
      self.column_contains({"#{self.table_name}.dept" => depts}, exception)
    end

    def assigned_scope(user_id)
      where("? in (user_primary_id, user_secondary_id)", user_id)
    end
  end
end
