module Kapa::Document::Concerns::BaseController
  extend ActiveSupport::Concern

  private
  def filter_defaults
    {:term_id => Kapa::Term.current_term.id,
     :type => :admission,
     :per_page => Rails.configuration.items_per_page}
  end
end
