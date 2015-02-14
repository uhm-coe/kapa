class Form < ApplicationBaseModel
  self.inheritance_column = nil
  belongs_to :person
  belongs_to :term
  has_one :transition_point

  def term_desc
    return term_id.blank? ? "No term chosen" : Term.find(term_id).description
  end

  def type_desc
    return ApplicationProperty.lookup_description(:form, type)
  end

  def lock?
    lock == "Y"
  end

  def submit
    self.update_attributes(:submitted_at => DateTime.now, :lock => "Y")
  end

  def date
    self.submitted_at
  end

  def name
    if self.term_id.blank?
      type_desc
    else
      "#{type_desc} (#{term_desc})"
    end
  end

  def self.search(filter, options = {})
    forms = Form.includes([:person])
    forms = forms.where("forms.term_id" => filter.term_id) if filter.term_id.present?
    forms = forms.where("forms.type" => filter.type.to_s) if filter.type.present?
    forms = forms.where{(self.public == "Y") | (self.dept.like_any filter.user.depts)} unless filter.user.manage? :artifact
    return forms
  end

  def self.to_csv(filter, options = {})
    forms = self.search(filter).order("submitted_at desc, persons.last_name, persons.first_name")
    CSV.generate do |csv|
      csv << self.csv_columns
      forms.each do |c|
        csv << self.csv_row(c)
      end
    end
  end

  def self.csv_columns
   [:id_number,
    :last_name,
    :first_name,
    :ssn,
    :ssn_agreement,
    :cur_street,
    :cur_city,
    :cur_state,
    :cur_postal_code,
    :cur_phone,
    :email,
    :updated,
    :submitted,
    :lock]
  end

  def self.csv_row(c)
   [c.rsend(:person, :id_number),
    c.rsend(:person, :last_name),
    c.rsend(:person, :first_name),
    c.rsend(:person, :ssn),
    c.rsend(:person, :ssn_agreement),
    c.rsend(:person, :contact, :cur_street),
    c.rsend(:person, :contact, :cur_city),
    c.rsend(:person, :contact, :cur_state),
    c.rsend(:person, :contact, :cur_postal_code),
    c.rsend(:person, :contact, :cur_phone),
    c.rsend(:person, :contact, :email),
    c.rsend(:updated_at),
    c.rsend(:submitted_at),
    c.rsend(:lock)]
  end
end
