class UserTimestamp < KapaBaseModel
  self.table_name = :timestamps
  belongs_to :user

  def self.search(filter, options = {})
    user_timestamps = UserTimestamp.includes([:user])
    user_timestamps = user_timestamps.where("date(convert_tz(created_at, '+00:00', '-10:00')) >= ?", filter.date_start) if filter.date_start.present?
    user_timestamps = user_timestamps.where("date(convert_tz(created_at, '+00:00', '-10:00')) <= ?", filter.date_end) if filter.date_end.present?
    user_timestamps = user_timestamps.where{self.path =~ "%#{filter.path}%"} if filter.path.present?
  end
end
