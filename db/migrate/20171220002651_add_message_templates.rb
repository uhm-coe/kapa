class AddMessageTemplates < ActiveRecord::Migration
  def change
    create_table :message_templates do |t|
      t.string   "title",      limit: 255
      t.text     "body",       limit: 65535
      t.string   "type",       limit: 255
      t.string   "sequence",   limit: 255
      t.string   "category",   limit: 255
      t.boolean  "active",                   default: true
      t.string   "dept",       limit: 255
      t.text     "yml",        limit: 65535
      t.text     "xml",        limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
