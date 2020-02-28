class AddVerbToTimestamps < ActiveRecord::Migration[5.2]
  def change
    add_column "timestamps", "method", :string
  end
end
