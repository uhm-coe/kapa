class PracticumProfile < ApplicationModel
  belongs_to :person
  belongs_to :curriculum
  has_many :practicum_placements

  def coordinator?(user)
    if user.manage?(:practicum, :delegate => :maintain)
      return true
    else
      return(self.coordinator_primary_uid == user.uid || self.coordinator_secondary_uid == user.uid)
    end
  end
end
