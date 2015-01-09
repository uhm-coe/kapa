class ConvertAcademicPeriodToTerm < ActiveRecord::Migration
  def up
    [Course, Form, PracticumPlacement, TransitionPoint].each do |t|
      t.update_all("term_id = (select id from terms where code = academic_period)")
    end
    AssessmentRubric.update_all("start_term_id = (select id from terms where code = academic_period_start), end_term_id = (select id from terms where code = academic_period_end)")
    ProgramOffer.all.each do |o|
      term_ids = []
      o.available_academic_period.split(/,\s*/).each do |a|
        term_ids.push(term_id(a))
      end
      o.update_attributes(:available_term_id => term_ids.join(","))
    end
  end

  def down
  end

  def term_id(academic_period)
    if @terms.nil?
      @terms = {}
      Term.all.each do |t|
        @terms[t.code] = t.id
      end
    end
    @terms[academic_period]
  end
end
