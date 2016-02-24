module Kapa::FacultyPublicationAuthorBase
  extend ActiveSupport::Concern

  included do
    self.table_name = :faculty_publications_authors
    belongs_to :faculty_publication
    validates_presence_of :faculty_publication_id
    validates_presence_of :person_id, :if => :internal?
    validates_presence_of :last_name, :first_name, :if => :external?
  end

  def internal?
    type == "internal"
  end

  def external?
    type == "external"
  end

  def person
    Kapa::Person.find_by(:id => person_id)
  end

  def full_name
    (internal?)? person.full_name : "#{last_name}, #{first_name} #{middle_initial}".strip
  end
end
