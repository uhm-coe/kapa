module Kapa::ProgramBase
  extend ActiveSupport::Concern

  included do
    attr_accessor :available_majors, :available_distributions, :available_tracks
    has_many :program_offers
    has_many :curriculums

    validates_uniqueness_of :code
    validates_presence_of :code

    before_validation :remove_extra_values
    before_save :join_attributes
  end

  def remove_extra_values
    remove_values(self.available_majors)
    remove_values(self.available_distributions)
    remove_values(self.available_tracks)
  end

  def join_attributes
    self.available_major = @available_majors ? @available_majors.join(",") : ""
    self.available_distribution = @available_distributions ? @available_distributions.join(",") : ""
    self.available_track = @available_tracks ? @available_tracks.join(",") : ""
  end

  def degree_desc
    return Kapa::Property.lookup_description(:degree, degree)
  end

  class_methods do
    def selections(options = {})
      options[:value] = :code if options[:value].nil?
      programs = where(:active => true)
      programs = programs.depts_scope(options[:depts]) if options[:depts]
      programs = programs.where(options[:conditions]) if options[:conditions]
      programs.order("sequence DESC, code").collect do |v|
        value = v.send(options[:value])
        description = ""
        description << "#{value}/" if options[:include_code]
        description << v.description
        [description, value]
      end
    end

    def search(filter, options = {})
      programs = Kapa::Program.all
      programs = programs.depts_scope(filter.dept) if filter.dept.present?
      programs = programs.where("programs.active" => filter.active) if filter.active.present?
      return programs
    end
  end
end
