class AddTypeOnExams < ActiveRecord::Migration
  def change
    add_column(:exams, :type, :string)
    rename_column(:files, :category, :type)
  end
end
