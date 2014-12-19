# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
require 'active_record/fixtures'

Person.delete_all
User.delete_all
person = Person.create(:last_name => "Admin", :first_name => "User")
user = person.users.create(:uid => "admin", :category => "local", :status => 3, :emp_status => 3)
user.password = "admin"
user.serialize(:role, {:main => '3', :artifact => '3', :advising => '3', :course => '3', :practicum => '3', :admin => '3'})
user.save!

ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db", "properties")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db", "programs")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db", "program_offers")


person = Person.create!(:last_name => "Adam", :first_name => "Tanners")
curriculum = person.curriculums.create!(:program => Program.find_by_code("EDEL-BED"))
curriculum.transition_points.create!(:type => :declaration, :academic_period => "201310")
curriculum.transition_points.create!(:type => :admission, :academic_period => "201310")
curriculum.transition_points.create!(:type => :graduation, :academic_period => "201410")

person.advising_sessions.create!(:session_date => Date.today, :session_type => "email")
person.advising_sessions.create!(:session_date => Date.today, :session_type => "email")
person.advising_sessions.create!(:session_date => Date.today, :session_type => "phone")
person.advising_sessions.create!(:session_date => Date.today, :session_type => "phone")
person.advising_sessions.create!(:session_date => Date.today, :session_type => "phone")

assessment_course1 = AssessmentCourse.create!(:academic_period => "201310", :crn => "111111", :subject => "ITE", :number => "401")
assessment_course2 = AssessmentCourse.create!(:academic_period => "201310", :crn => "111112", :subject => "ITE", :number => "402")
assessment_course3 = AssessmentCourse.create!(:academic_period => "201310", :crn => "111113", :subject => "ITE", :number => "403")
person.assessment_course_registrations.create!(:assessment_course => assessment_course1)
person.assessment_course_registrations.create!(:assessment_course => assessment_course2)
person.assessment_course_registrations.create!(:assessment_course => assessment_course3)
