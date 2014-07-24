class Advising::BaseController < ApplicationController

  private
  def filter_defaults
    {:date_start => Date.today, :date_end => Date.today}
  end
end
