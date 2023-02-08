class DropDatasets < ActiveRecord::Migration[5.2]

  def change
    drop_table :datasets
  end

end
