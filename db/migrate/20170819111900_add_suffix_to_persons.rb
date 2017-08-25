class AddSuffixToPersons < ActiveRecord::Migration
  def change
    add_column "persons", "suffix", :string
  end
end
