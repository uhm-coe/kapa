module Kapa::CaseActionBase
  extend ActiveSupport::Concern

  included do
    belongs_to :case
    belongs_to :person
    belongs_to :user

    validates_presence_of :case_id, :action, :action_date, :user_id
    before_save :copy_type
  end

  #Type field needs to be copied here for improving query performance
  def copy_type
    self.type = self.case.type
  end

  def action_desc
    Kapa::Property.lookup_description("#{self.type}_action", action)
  end
end
