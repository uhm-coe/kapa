class RenameAssessmentCourses < ActiveRecord::Migration

  def change
    rename_table(:assessment_courses, :courses)
    rename_table(:assessment_course_registrations, :course_registrations)
    rename_column(:course_registrations, :assessment_course_id, :course_id)
    AssessmentScore.update_all("assessment_scorable_type = 'CourseRegistration'", "assessment_scorable_type = 'AssessmentCourseRegistration'")
  end

end
