require "kapa/engine"

module Kapa

  def self.beta?
    ENV['RELEASE'] != "live"
  end

  def self.debug(*args)
    Rails.logger.debug("*DEBUG* " + args.collect {|a| a.inspect}.join(", "))
  end

end
