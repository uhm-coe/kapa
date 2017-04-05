class DeleteEndTermIdOnPlacements < ActiveRecord::Migration
  def change
    change_table :practicum_placements, :bulk => true do |t|
      t.rename :start_term_id, :term_id
      t.remove :end_term_id
    end
  end
end
