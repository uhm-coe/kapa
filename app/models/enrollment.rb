class Enrollment < KapaBaseModel
  belongs_to :person
  belongs_to :term
  belongs_to :user_primary,
             :class_name => "User",
             :foreign_key => "user_primary_id"
  belongs_to :user_secondary,
             :class_name => "User",
             :foreign_key => "user_secondary_id"

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
