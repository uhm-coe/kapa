# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#require 'active_record/fixtures'

Kapa::Person.delete_all
Kapa::User.delete_all

#Load sample data
fixtures = %w(
  properties
  programs
  program_offers
  terms
  persons
  curriculums
  advising_sessions
  transition_points
  transition_actions
  courses
  course_registrations
  enrollments
  practicum_placements
  practicum_sites
  datasets
).each do |f|
  ActiveRecord::Fixtures.create_fixtures("#{Kapa::Engine.root}/test/fixtures", f)
end

#Create a sample user on each role
Rails.configuration.roles.each_key do |name|
  person = Kapa::Person.create(:last_name => name, :first_name => "User")
  user = person.users.create(:uid => name.downcase, :category => "local", :status => 3, :emp_status => 3)
  user.password = name.downcase
  user.apply_role(name)
  user.save!
end

[Kapa::AdvisingSession].each do |c|
  c.update_all(:session_date => Date.today)
end
