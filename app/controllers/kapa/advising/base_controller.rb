class Kapa::Advising::BaseController < Kapa::ApplicationBaseController

  private
  def filter_defaults
    {:date_start => Date.today, :date_end => Date.today}
  end
end
