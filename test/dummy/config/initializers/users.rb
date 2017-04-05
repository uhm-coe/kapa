# Be sure to restart your server when you modify this file.

# Define default user levels and scopes
Rails.configuration.user_levels = [["No Access", "0"], ["Read", "10"], ["Write", "20"], ["Manage", "30"]]
Rails.configuration.user_scopes = [["Assigned records", "10"], ["Assigned or Dept records", "20"], ["All records", "30"]]
Rails.configuration.user_status = [["No Access", "0"],["Guest" , "10"],["User" , "30"]]
Rails.configuration.user_categories = [["LDAP", "ldap"],["Local" , "local"]]

# Define user roles (pre-defined permissions)
Rails.configuration.roles = {}
Rails.configuration.roles["Admin"] = Rails.configuration.available_routes.each_with_object({}) {|route, permission|
  permission["#{route}"] = '30'
  permission["#{route}_scope"] = '30'
}
Rails.configuration.roles["None"] = Rails.configuration.available_routes.each_with_object({}) {|route, permission|
  permission["#{route}"] = '0'
  permission["#{route}_scope"] = '0'
}
