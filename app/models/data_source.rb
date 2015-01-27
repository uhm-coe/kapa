class DataSource < ApplicationBaseModel
  attr_accessible :name, :password, :type, :url, :user
  self.inheritance_column = nil

  has_many :data_sets

  def connection
    Sequel.connect(self.url, :user => self.user, :password => self.password)
  end

  def self.local_connection
    Sequel.connect(Rails.configuration.database_configuration[Rails.env])
  end
end
