class Admin::BaseController < ApplicationBaseController

  private
  def filter_defaults
    {:type => :admission,
     :active => 1,
     :name => :academic_period,
     :date_start => Date.today,
     :date_end => Date.today,
     :start_term_id => Term.current_term.id,
     :end_term_id => Term.current_term.id}
  end
end
