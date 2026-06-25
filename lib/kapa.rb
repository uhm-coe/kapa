require "kapa/engine"
require "csv"
require "stringio"
require 'net/http'

module Kapa

  def self.beta?
    ENV['APP_RELEASE'] != "live"
  end

  def self.debug(*args)
    Rails.logger.debug("*DEBUG* " + args.collect {|a| a.inspect}.join(", "))
  end

end
