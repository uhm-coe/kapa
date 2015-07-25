class Kapa::CsvSerializer
  def self.load(value)
    value.to_s.split(/,\s*/)
  end

  def self.dump(value)
    value.delete_if {|v| v.blank?}.join(",")
  end
end
