class ConvertAcademicPeriodToTerm < ActiveRecord::Migration
  def up
    [Kapa::CourseOffer, Kapa::Form, Kapa::PracticumPlacement, Kapa::TransitionPoint].each do |t|
      t.update_all("term_id = (select id from terms where code = academic_period)")
    end
    Kapa::AssessmentRubric.update_all("start_term_id = (select id from terms where code = academic_period_start)")
    Kapa::AssessmentRubric.update_all("end_term_id = (select id from terms where code = academic_period_end)")
    Kapa::ProgramOffer.all.each do |o|
      term_ids = o.available_academic_period.split(/,\s*/).sort
      o.update_attribute(:start_term_id, term_ids.first.to_i)
      o.update_attribute(:end_term_id, term_ids.last.to_i)
    end
  end

  def down
  end

  def term_id(academic_period)
    if @terms.nil?
      @terms = {}
      Kapa::Term.all.each do |t|
        @terms[t.code] = t.id
      end
    end
    @terms[academic_period]
  end
end
