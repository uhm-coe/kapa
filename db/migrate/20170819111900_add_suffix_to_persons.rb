class AddSuffixToPersons < ActiveRecord::Migration[5.2]
  def change
    add_column "persons", "suffix", :string
  end
end
