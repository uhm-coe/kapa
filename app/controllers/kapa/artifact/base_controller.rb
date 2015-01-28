class Kapa::Artifact::BaseController < Kapa::KapaBaseController
  private
  def filter_defaults
    {:term_id => Term.current_term.id,
     :type => :admission,
    }
  end
end
