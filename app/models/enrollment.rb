class Enrollment < KapaBaseModel
  belongs_to :curriculum
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

  def self.search(filter, options = {})
    enrollments = Enrollment.includes([{:curriculum => :person}, {:curriculum => :program}])
    enrollments = enrollments.where("enrollments.term_id" => filter.term_id) if filter.term_id.present?
    if filter.program == "NA"
      enrollments = enrollments.where("programs.code is NULL")
    else
      enrollments = enrollments.where("programs.code" => filter.program) if filter.program.present?
    end
    enrollments = enrollments.where("curriculums.distribution" => filter.distribution) if filter.distribution.present?
    enrollments = enrollments.where("curriculums.major_primary" => filter.major) if filter.major.present?
    enrollments = enrollments.where("enrollments.category" => filter.category) if filter.category.present?

    case filter.user.access_scope
    when 3
      # do nothing
    when 2
      enrollments = enrollments.where("programs.code" => filter.user.depts)
    when 1
      enrollments = enrollments.where{({enrollments => user_primary_id} == my{filter.user.id}) | ({enrollments => user_secondary_id} == my{filter.user.id})} unless @current_user.manage?
    else
      enrollments = enrollments.where("1 = 2")  #Do not list any objects
    end
    return enrollments
  end
end
