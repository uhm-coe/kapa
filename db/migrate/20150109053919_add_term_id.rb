class AddTermId < ActiveRecord::Migration
  def change
    [:course_offers, :forms, :practicum_placements, :transition_points].each do |t|
      add_column(t, :term_id, :integer)
      add_index(t, :term_id)
    end

    [:assessment_rubrics, :program_offers].each do |t|
      add_column(t, :start_term_id, :integer)
      add_index(t, :start_term_id)
      add_column(t, :end_term_id, :integer)
      add_index(t, :end_term_id)
    end
  end
end
