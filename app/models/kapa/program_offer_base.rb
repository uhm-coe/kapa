module Kapa::ProgramOfferBase
  extend ActiveSupport::Concern

  included do
    serialize :available_major, Kapa::CsvSerializer
    belongs_to :program

    validates_presence_of :distribution, :program_id
    validates_uniqueness_of :distribution, :scope => :program_id
  end

  class_methods do
    def selections(options = {})
      options[:value] = :distribution if options[:value].nil?
      program_offers = where(:active => true)
      program_offers = program_offers.depts_scope(options[:depts]) if options[:depts].present?
      program_offers = program_offers.where(options[:conditions]) if options[:conditions].present?
      program_offers.order("sequence DESC, distribution").collect do |v|
        value = v.send(options[:value])
        description = ""
        description << "#{value}/" if options[:include_code]
        description << v.description
        [description, value]
      end
    end
  end
end
