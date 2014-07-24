class ApplicationModel < ActiveRecord::Base
  self.abstract_class = true
  serialize :yml, Hash
#  before_save :update_xml

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
#    value = {} if value.nil?
    logger.debug "----value: #{value.inspect}"
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

  def self.selections
    [["Not Defined!", "ND"]]
  end

  private
  def to_end_of_day(value)
    DateTime.new(value.year, value.month, value.day, 23, 59, 0, 0) if value.is_a? Date
  end

  def checksum(string)
    Digest::SHA1.hexdigest(string)
  end
end
