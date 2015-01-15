class Practicum::BaseController < ApplicationBaseController

  private
  def filter_defaults
    {:term_id => current_term, :term_type => "admission", :assignment_type => "mentor"}
  end
end