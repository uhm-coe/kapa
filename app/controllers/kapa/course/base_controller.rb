class Kapa::Course::BaseController < Kapa::ApplicationBaseController

  private
  def filter_defaults
    {:term_id => Term.current_term.id}
  end
end
