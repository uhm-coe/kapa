module Kapa::FormDetailBase
  extend ActiveSupport::Concern

  included do
    belongs_to :form
    belongs_to :form_field
  end

  def rating_desc
    if self.form_field.type == "select" and self.form_field.type_option
      return Kapa::Property.lookup_description(form_field.type_option, self.rating)
    else
      return self.rating
    end
  end

  class_methods do
    def scores(assessment_scorables, form_template)
      #initialize table first
      scores = ActiveSupport::OrderedHash.new
      assessment_scorables.each do |s|
        form_template.form_fields.each do |c|
          index = "#{s.id}_#{c.id}"
          scores[index] = ""
        end
      end
      #then, fill in scores using ActiveRecord cache.  this is more efficient than filing everything one by one (save SQL execution)
      self.where(:assessment_scorable_type => assessment_scorables.first.class, :assessment_scorable_id => assessment_scorables.collect {|s| s.id}).each do |score|
        index = "#{score.assessment_scorable_id}_#{score.form_field_id}"
        scores[index] = score.rating if scores[index]
      end
      return scores
    end
  end
end
