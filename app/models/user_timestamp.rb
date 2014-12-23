class UserTimestamp < ActiveRecord::Base
  self.table_name = :timestamps
  belongs_to :user
end
