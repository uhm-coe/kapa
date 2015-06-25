class AddTypeOnExams < ActiveRecord::Migration
  def change
    add_column(:exams, :type, :string)
    rename_column(:documents, :category, :type)
  end
end
