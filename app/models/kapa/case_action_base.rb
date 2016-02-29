module Kapa::CaseActionBase
  extend ActiveSupport::Concern

  included do
    belongs_to :case
    has_one :user_assignment, :as => :assignable
    has_one :user, :through => :user_assignment

    validates_presence_of :case_id, :action, :action_date
    before_save :copy_type
  end

  #This type field needs to be exist in this model due to query performance
  def copy_type
    self.type = self.case.type
  end

  def action_desc
    Kapa::Property.lookup_description("#{self.case.type}_action", action)
  end
end
