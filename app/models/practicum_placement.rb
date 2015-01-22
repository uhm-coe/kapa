class PracticumPlacement < ApplicationBaseModel
  belongs_to :practicum_profile
  has_many :practicum_assignments, :dependent => :destroy
  belongs_to :user_primary,
             :class_name => "User",
             :foreign_key => "user_primary_id"
  belongs_to :user_secondary,
             :class_name => "User",
             :foreign_key => "user_secondary_id"

  #before_save :update_group
  #
  #def update_group
  #  users = []
  #  users.push(user_primary.uid) unless user_primary.blank?
  #  users.push(user_secondary.uid) unless user_secondary.blank?
  #  self.uid = users.sort.join(".")
  #end

  def practicum_assignments_select(assignment_type , index = nil)
    assignments = self.practicum_assignments.select {|a| a.assignment_type == assignment_type.to_s}
    if index
      return assignments[index]
    else
      return assignments
    end
  end

  def term_desc
    return Term.find(term_id).description
  end

  def assignment_desc(assignment_type)
    practicum_assignments_select(assignment_type).collect {|a| a.name}.join(", ")
  end
end
