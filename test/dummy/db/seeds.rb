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
  persons
  text_templates
).each do |f|
  ActiveRecord::FixtureSet.create_fixtures("#{Kapa::Engine.root}/test/fixtures", f)
end

#Create admin user
person = Kapa::Person.create(:last_name => "Admin", :first_name => "User")
user = person.users.create(:uid => "admin", :category => "local", :status => 30)
user.password = "admin"
user.apply_role("Admin")
user.save!(validate: false)

Kapa::FormTemplate.delete_all
form_template = Kapa::FormTemplate.create(:title => "Sample Form", :type => "simple")
form_template.form_template_fields.create(:label => "Name", :sequence => 1, :type => "text_field")
form_template.form_template_fields.create(:label => "Email", :sequence => 2, :type => "text_field")
form_template.form_template_fields.create(:label => "Phone", :sequence => 3, :type => "text_field")
form_template.form_template_fields.create(:label => "Preferred contact", :sequence => 4, :type => "csv_select", :type_option => "Email, Phone")
form_template.form_template_fields.create(:label => "Department", :sequence => 5, :type => "property_select", :type_option => "dept")
form_template.form_template_fields.create(:label => "Comment", :sequence => 6, :type => "text_area")
