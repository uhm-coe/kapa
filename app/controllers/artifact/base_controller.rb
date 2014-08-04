class Artifact::BaseController < ApplicationBaseController
  private
  def filter_defaults
    {:academic_period => current_academic_period,
     :type => :admission,
    }
  end
end
