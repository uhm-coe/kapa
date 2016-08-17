module Kapa::PracticumLogBase
  extend ActiveSupport::Concern

  included do
    belongs_to :practicum_placement
    belongs_to :user
    validates_presence_of :log_date
  end

  def type_desc
    return Kapa::Property.lookup_description(:practicum_log_type, type)
  end

  def category_desc
    return Kapa::Property.lookup_description(:practicum_log_category, category)
  end

  def task_desc
    return Kapa::Property.lookup_description(:practicum_log_task, task)
  end

  class_methods do
  end

end
