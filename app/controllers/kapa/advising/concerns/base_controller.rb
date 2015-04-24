module Kapa::Advising::Concerns::BaseController
  extend ActiveSupport::Concern

  private
  def filter_defaults
    {:date_start => Date.today, :date_end => Date.today, :per_page => Rails.configuration.items_per_page}
  end
end
