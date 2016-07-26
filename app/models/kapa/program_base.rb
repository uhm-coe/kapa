module Kapa::ProgramBase
  extend ActiveSupport::Concern

  included do
    serialize :dept, Kapa::CsvSerializer
    serialize :available_major, Kapa::CsvSerializer
    serialize :available_distribution, Kapa::CsvSerializer
    serialize :available_track, Kapa::CsvSerializer
    has_many :program_offers
    has_many :curriculums
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

    validates_uniqueness_of :code
    validates_presence_of :code
  end

  def degree_desc
    return Kapa::Property.lookup_description(:degree, degree)
  end

  class_methods do
    def selections(options = {})
      options[:value] = :code if options[:value].nil?
      programs = where(:active => true)
      programs = programs.depts_scope(options[:depts]) if options[:depts].present?
      programs = programs.where(options[:conditions]) if options[:conditions].present?
      programs.order("sequence DESC, code").collect do |v|
        value = v.send(options[:value])
        description = ""
        description << "#{value}/" if options[:include_code]
        description << v.description
        [description, value]
      end
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      programs = Kapa::Program.all.order("code")
      programs = programs.depts_scope(filter.dept) if filter.dept.present?
      programs = programs.where("programs.active" => filter.active) if filter.active.present?
      return programs
    end
  end
end
