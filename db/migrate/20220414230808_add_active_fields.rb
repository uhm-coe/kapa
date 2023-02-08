class AddActiveFields < ActiveRecord::Migration[5.2]

  def change
    add_column(:forms, :active, :boolean, :default => 1)
    add_column(:files, :active, :boolean, :default => 1)
    add_column(:texts, :active, :boolean, :default => 1)
  end

end
