class RenameAssessmentCourses < ActiveRecord::Migration

  def change
    rename_table(:assessment_courses, :course_offers)
    rename_table(:assessment_course_registrations, :course_registrations)
    rename_column(:course_registrations, :assessment_course_id, :course_offer_id)
    Kapa::AssessmentScore.where(:assessment_scorable_type => 'AssessmentCourseRegistration').update_all("assessment_scorable_type = 'CourseRegistration'")
  end

end
