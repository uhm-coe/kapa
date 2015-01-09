class AddTermId < ActiveRecord::Migration
  def change
    [:courses, :forms, :practicum_placements, :transition_points].each do |t|
      add_column(t, :term_id, :integer)
      add_index(t, :term_id)
    end
    add_column(:assessment_rubrics, :start_term_id, :integer)
    add_index(:assessment_rubrics, :start_term_id)
    add_column(:assessment_rubrics, :end_term_id, :integer)
    add_index(:assessment_rubrics, :end_term_id)
    add_column(:program_offers, :available_term_id, :integer)
  end
end
