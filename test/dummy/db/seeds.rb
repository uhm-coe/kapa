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

fixture_path = "#{Rails.root.parent}/fixtures"
ActiveRecord::Fixtures.create_fixtures(fixture_path, "properties")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "programs")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "program_offers")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "terms")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "persons")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "curriculums")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "advising_sessions")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "transition_points")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "transition_actions")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "courses")
ActiveRecord::Fixtures.create_fixtures(fixture_path, "course_registrations")

[TransitionPoint, Course].each do |c|
  c.update_all(:term_id => Term.current_term.id)
end

[AdvisingSession].each do |c|
  c.update_all(:session_date => Date.today)
end

person = Person.create(:last_name => "Admin", :first_name => "User")
user = person.users.create(:uid => "admin", :category => "local", :status => 3, :emp_status => 3)
user.password = "admin"
user.serialize(:role, {:main => '3', :main_list => '3', :artifact => '3', :artifact_list => '3', :advising => '3', :advising_list => '3', :course => '3', :course_list => '3', :practicum => '3', :practicum_list => '3', :admin => '3'})
user.save!
