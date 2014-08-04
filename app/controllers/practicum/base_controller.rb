class Practicum::BaseController < ApplicationBaseController

  private
  def filter_defaults
    {:academic_period => current_academic_period, :academic_period_type => "admission", :assignment_type => "mentor"}
  end
end