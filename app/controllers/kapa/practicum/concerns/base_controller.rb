module Kapa::Practicum::Concerns::BaseController
  extend ActiveSupport::Concern

  private
  def filter_defaults
    {:term_id => Term.current_term.id, :per_page => Rails.configuration.items_per_page}
  end
end
