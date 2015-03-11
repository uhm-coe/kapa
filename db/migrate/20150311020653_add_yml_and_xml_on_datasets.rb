class AddYmlAndXmlOnDatasets < ActiveRecord::Migration
  def change
    add_column(:datasets, :yml, :text)
    add_column(:datasets, :xml, :text)
  end
end
