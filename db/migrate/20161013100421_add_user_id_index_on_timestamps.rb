class AddUserIdIndexOnTimestamps < ActiveRecord::Migration[4.2]

  def change
    change_table :timestamps, :bulk => true do |t|
      t.index :user_id
    end
  end
end