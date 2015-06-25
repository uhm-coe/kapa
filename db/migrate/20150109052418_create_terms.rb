class CreateTerms < ActiveRecord::Migration
  def change

    create_table "terms", :force => true do |t|
      t.string   "code"
      t.string   "description"
      t.string   "description_short"
      t.date     "start_date"
      t.date     "end_date"
      t.integer  "sequence"
      t.boolean  "active",                                   :default => true
      t.string   "dept"
      t.text     "yml"
      t.text     "xml"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    ActiveRecord::Fixtures.create_fixtures("#{Kapa::Engine.root}/test/fixtures", "terms")
  end
end
