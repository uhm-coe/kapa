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
user.apply_role(:admin)
user.save!
