class Kapa::Course::BaseController < Kapa::KapaBaseController

  private
  def filter_defaults
    {:term_id => Term.current_term.id, :per_page => Rails.configuration.items_per_page}
  end
end
