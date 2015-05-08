module Kapa::Concerns::PracticumSite
  extend ActiveSupport::Concern

  included do
    has_many :practicum_placements
    validates_presence_of :name, :code
    validates_uniqueness_of :code
  end # included

  def site_contact
    self.deserialize(:site_contact, :as => OpenStruct)
  end

  def grades
    if level_from != "99"
      "#{level_from.to_s.sub("0", "K")}-#{level_to.to_s.sub("0", "K")}"
    else
      "N/A"
    end
  end

  module ClassMethods
    def search(filter, options = {})
      sites = Kapa::PracticumSite.includes([:practicum_placements])
      sites = sites.column_matches(:name => filter.name) if filter.name.present?
      # f.append_condition "? between level_from and level_to", :grade # TODO: Is this still needed?
      sites = sites.where("district" => filter.district) if filter.district.present?
      sites = sites.where("area_group" => filter.area_group) if filter.area_group.present?
      return sites;
    end

    def to_csv(filter, options = {})
      sites = self.search(filter).order("name_short")
      CSV.generate do |csv|
        csv << self.csv_columns
        sites.each do |c|
          csv << self.csv_row(c)
        end
      end
    end

    def csv_columns
      [:site_code,
       :area_group,
       :district,
       :level_from,
       :level_to,
       :category,
       :name,
       :name_short,
       :area,
       :area_group,
       :principal_last_name,
       :principal_first_name,
       :street,
       :city,
       :state,
       :postal_code,
       :phone,
       :fax]
    end

    def csv_row(c)
      [c.rsend(:code),
       c.rsend(:area_group),
       c.rsend(:district),
       c.rsend(:level_from),
       c.rsend(:level_to),
       c.rsend(:category),
       c.rsend(:name),
       c.rsend(:name_short),
       c.rsend(:area),
       c.rsend(:area_group),
       c.rsend(:site_contact, :principal_first_name),
       c.rsend(:site_contact, :principal_last_name),
       c.rsend(:site_contact, :street),
       c.rsend(:site_contact, :city),
       c.rsend(:site_contact, :state),
       c.rsend(:site_contact, :postal_code),
       c.rsend(:site_contact, :phone),
       c.rsend(:site_contact, :fax)]
    end
  end
end
