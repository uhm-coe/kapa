module Kapa::Admin::BaseControllerBase
  extend ActiveSupport::Concern

  private
  def filter_defaults
    {:type => :admission,
     :active => 1,
     :name => :term_id,
     :date_start => Date.today,
     :date_end => Date.today,
     :start_term_id => Kapa::Term.current_term.id,
     :end_term_id => Kapa::Term.current_term.id,
     :per_page => Rails.configuration.items_per_page}
  end
end
