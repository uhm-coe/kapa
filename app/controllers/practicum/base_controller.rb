class Practicum::BaseController < ApplicationBaseController

  private
  def filter_defaults
    {:term_id => Term.current_term.id, :term_type => "admission", :assignment_type => "mentor"}
  end
end