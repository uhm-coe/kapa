class Kapa::Advising::BaseController < Kapa::KapaBaseController

  private
  def filter_defaults
    {:date_start => Date.today, :date_end => Date.today, :per_page => Rails.configuration.items_per_page}
  end
end
