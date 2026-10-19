class SetPdfTypeOnContents < ActiveRecord::Migration[8.1]
  # Content types are now "email" and "pdf". PDF templates (letters) had a blank type or "letter".
  def up
    execute "UPDATE contents SET type = 'pdf' WHERE type IS NULL OR type <> 'email'"
  end

  def down
    execute "UPDATE contents SET type = '' WHERE type = 'pdf'"
  end
end
