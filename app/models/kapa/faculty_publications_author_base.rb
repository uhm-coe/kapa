module Kapa::FacultyPublicationsAuthorBase
  extend ActiveSupport::Concern

  included do
    self.table_name = :faculty_publications_authors
    belongs_to :faculty_publication
    validates_presence_of :faculty_publication_id
  end

  def person?
    person_id.present?
  end

  def person
    Kapa::Person.find_by(:id => person_id)
  end

  def full_name
    (person?)? person.full_name : "#{last_name}, #{first_name} #{middle_initial}"
  end
end
