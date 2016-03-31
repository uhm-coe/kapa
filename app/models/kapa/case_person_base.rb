module Kapa::CasePersonBase
  extend ActiveSupport::Concern

  included do
    self.table_name = :case_persons
    belongs_to :person
    belongs_to :case
  end

  def type_desc
    return Kapa::Property.lookup_description("case_person_type", self.type)
  end

  def internal?
    self.person_id.present?
  end

  def full_name
    if internal?
      self.person.full_name
    else
      person = self.deserialize(:person_profile, :as => OpenStruct)
      "#{person.last_name}, #{person.first_name}"
    end
  end

  def email
    if internal?
      self.person.email_preferred
    else
      contact = self.deserialize(:person_contact, :as => OpenStruct)
      contact.email
    end
  end

  def phone
    if internal?
      self.person.contact.cur_phone if self.person.contact
    else
      contact = self.deserialize(:person_contact, :as => OpenStruct)
      contact.phone
    end
  end
end
