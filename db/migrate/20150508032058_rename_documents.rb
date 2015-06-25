class RenameDocuments < ActiveRecord::Migration
  def change
    rename_table(:documents, :files)
  end
end
