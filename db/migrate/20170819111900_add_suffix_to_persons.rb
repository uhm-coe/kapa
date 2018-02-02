class AddSuffixToPersons < ActiveRecord::Migration[4.2]
  def change
    add_column "persons", "suffix", :string
  end
end
