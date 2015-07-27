module Kapa::UserTimestampBase
  extend ActiveSupport::Concern

  included do
    self.table_name = :timestamps
    belongs_to :user
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      user_timestamps = Kapa::UserTimestamp.eager_load([:user])
      user_timestamps = user_timestamps.where("date(convert_tz(created_at, '+00:00', '-10:00')) >= ?", filter.date_start) if filter.date_start.present?
      user_timestamps = user_timestamps.where("date(convert_tz(created_at, '+00:00', '-10:00')) <= ?", filter.date_end) if filter.date_end.present?
      user_timestamps = user_timestamps.column_matches(:path => filter.path) if filter.path.present?
    end
  end
end
