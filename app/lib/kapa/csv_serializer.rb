# Stores an array as a comma-separated string. Use as a serialize coder:
#   serialize :licensure, :coder => Kapa::CsvSerializer
module Kapa::CsvSerializer
  def self.load(value)
    value.to_s.split(/,\s*/)
  end

  def self.dump(value)
    Array(value).reject(&:blank?).join(",")
  end
end
