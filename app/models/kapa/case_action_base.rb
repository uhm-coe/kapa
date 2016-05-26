module Kapa::CaseActionBase
  extend ActiveSupport::Concern

  included do
    belongs_to :case
    belongs_to :person
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

    validates_presence_of :case_id, :action, :action_date
    before_save :copy_type
  end

  #Type field needs to be copied here for improving query performance
  def copy_type
    self.type = self.case.type
  end

  def action_desc
    if self.action == "RM"
      Kapa::Property.lookup_description("#{self.type}_action", action) + " to #{self.action_specify}"
    else
      Kapa::Property.lookup_description("#{self.type}_action", action)
    end
  end
end
