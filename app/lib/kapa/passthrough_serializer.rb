# Serialize coder that stores and returns the value unchanged (no encoding).
# Not used in this gem, but apps that use kapa still reference it.
module Kapa::PassthroughSerializer
  def self.load(value)
    value
  end

  def self.dump(value)
    value
  end
end
