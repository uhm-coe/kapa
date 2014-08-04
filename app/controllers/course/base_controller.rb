class Course::BaseController < ApplicationBaseController

  private
  def filter_defaults
    {:academic_period => current_academic_period}
  end
end
