class AddUserIdIndexOnTimestamps < ActiveRecord::Migration

  def change
    change_table :timestamps, :bulk => true do |t|
      t.index :user_id
    end
  end
end