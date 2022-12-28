# Be sure to restart your server when you modify this file.

#Authlogic configuration
Rails.configuration.acts_as_authentic_options = {}

# Define default user levels and scopes
Rails.configuration.user_levels = [["No Access", "0"], ["Read", "10"], ["Write", "20"], ["Manage", "30"]]
Rails.configuration.user_scopes = [["Assigned records", "10"], ["Assigned or Dept records", "20"], ["All records", "30"]]
Rails.configuration.user_status = [["No Access", "0"],["Active Guest" , "10"],["Active User" , "30"], ["Active User (Overridden)" , "40"]]
Rails.configuration.user_categories = [["LDAP", "ldap"],["Local" , "local"]]

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
