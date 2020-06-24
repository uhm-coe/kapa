# Be sure to restart your server when you modify this file.

#Authlogic configuration
Rails.configuration.acts_as_authentic_options = {}

# Define default user levels and scopes
Rails.configuration.user_scopes = {"10" => "Assigned records", "20" => "Assigned or Dept records", "30" => "All records"}
Rails.configuration.user_status = {"0" => "No Access", "10" => "Guest", "30" => "User"
Rails.configuration.user_categories = {"ldap" => "LDAP", "local" => "Local"}

# Define user roles (permissions to each kapa controller)
# R = Read (index and show)
# U = Update
# C = Create
# D = Destroy
# I = Import
# E = Export
# M = Manage
Rails.configuration.roles = {}
Rails.configuration.roles["Admin"] = Rails.configuration.available_routes.each_with_object({}) {|route, permission|
  permission["#{route}"] = 'RUCDIEM'
  permission["#{route}_scope"] = '30'
}
Rails.configuration.roles["None"] = Rails.configuration.available_routes.each_with_object({}) {|route, permission|
  permission["#{route}"] = ''
  permission["#{route}_scope"] = '0'
}
