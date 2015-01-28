class Kapa::Practicum::BaseController < Kapa::KapaBaseController

  private
  def filter_defaults
    {:term_id => Term.current_term.id, :term_type => "admission", :assignment_type => "mentor"}
  end
end