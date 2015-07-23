# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
require 'active_record/fixtures'

Kapa::Person.delete_all
Kapa::User.delete_all

fixture_path = "#{Kapa::Engine.root}/test/fixtures"
ActiveRecord::Fixtures.create_fixtures(fixture_path, "properties")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "programs")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "program_offers")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "terms")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "persons")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "curriculums")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "advising_sessions")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "transition_points")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "transition_actions")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "course_offers")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "course_registrations")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "enrollments")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "practicum_placements")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "practicum_sites")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "datasets")

[Kapa::AdvisingSession].each do |c|
  c.update_all(:session_date => Date.today)
end

person = Kapa::Person.create(:last_name => "Admin", :first_name => "User")
user = person.users.create(:uid => "admin", :category => "local", :status => 3, :emp_status => 3)
user.password = "admin"
permission = {}
 [:kapa_main_persons,
  :kapa_main_contacts,
  :kapa_main_curriculums,
  :kapa_main_transition_points,
  :kapa_main_transition_actions,
  :kapa_main_enrollments,
  :kapa_document_files,
  :kapa_document_forms,
  :kapa_document_exams,
  :kapa_advising_sessions,
  :kapa_course_offers,
  :kapa_course_registrations,
  :kapa_practicum_placements,
  :kapa_practicum_sites,
  :kapa_admin_criterions,
  :kapa_admin_datasets,
  :kapa_admin_programs,
  :kapa_admin_properties,
  :kapa_admin_rubrics,
  :kapa_admin_terms,
  :kapa_admin_users].each do |o|
  permission["#{o}"] = '3'
  permission["#{o}_scope"] = '3'
end
user.serialize(:permission, permission)
user.save!
