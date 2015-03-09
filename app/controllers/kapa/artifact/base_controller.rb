class Kapa::Artifact::BaseController < Kapa::KapaBaseController
  private
  def filter_defaults
    {:term_id => Term.current_term.id,
     :type => :admission,
     :per_page => Rails.configuration.items_per_page}
  end
end
