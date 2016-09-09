class AddBibtexFields < ActiveRecord::Migration
  def change
    change_table :faculty_publications, :bulk => true do |t|
      t.string "category"
      t.string "annote"
      t.text "author"
      t.string "how_published"
      t.string "journal"
      t.string "key"
      t.text "note"
      t.string "issue_number"
      t.string "school"
      t.string "series"
      t.string "crossref"
      t.text "bibtex"
      t.remove "num_of_vol"
    end
  end
end