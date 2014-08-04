class Admin::BaseController < ApplicationBaseController

  private
  def filter_defaults
    {:type => :admission,
     :active => 1,
     :name => :academic_period,
     :date_start => Date.today,
     :date_end => Date.today,
     :academic_period_first => current_academic_period,
     :academic_period_last => current_academic_period}
  end
end
