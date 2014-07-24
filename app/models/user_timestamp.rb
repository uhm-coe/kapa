class UserTimestamp < ActiveRecord::Base
  set_table_name :timestamps
  belongs_to :user
end
