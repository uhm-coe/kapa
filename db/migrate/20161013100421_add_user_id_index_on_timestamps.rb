class AddUserIdIndexOnTimestamps < ActiveRecord::Migration[5.2]

  def change
    change_table :timestamps, :bulk => true do |t|
      t.index :user_id
    end
  end
end