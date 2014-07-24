class Course::BaseController < ApplicationController

  private
  def filter_defaults
    {:academic_period => current_academic_period}
  end
end
