class AddTermFieldsOnTerms < ActiveRecord::Migration
  def up
    add_column(:terms, :academic_year, :string)
    add_column(:terms, :calendar_year, :string)
    add_column(:terms, :fiscal_year, :string)
    add_column(:terms, :regular_term, :boolean)
  end

  def down
  end
end
