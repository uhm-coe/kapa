module Kapa::PracticumSiteBase
  extend ActiveSupport::Concern

  included do
    has_many :practicum_placements
    validates_presence_of :name, :code
    validates_uniqueness_of :code
    obfuscate_id
  end

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

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      sites = Kapa::PracticumSite.eager_load([:practicum_placements]).order("name_short")
      sites = sites.column_matches(:name => filter.name) if filter.name.present?
      # f.append_condition "? between level_from and level_to", :grade # TODO: Is this still needed?
      sites = sites.where("district" => filter.district) if filter.district.present?
      sites = sites.where("area_group" => filter.area_group) if filter.area_group.present?
      return sites;
    end

    def csv_format
      {:site_code => [:code],
       :area_group => [:area_group],
       :district => [:district],
       :level_from => [:level_fro],
       :level_to => [:level_to],
       :category => [:category],
       :name => [:name],
       :name_short => [:name_short],
       :area => [:area],
       :area_group => [:area_group],
       :principal_last_name => [:site_contact, :principal_first_name],
       :principal_first_name => [:site_contact, :principal_last_name],
       :street => [:site_contact, :street],
       :city => [:site_contact, :city],
       :state => [:site_contact, :state],
       :postal_code => [:site_contact, :postal_code],
       :phone => [:site_contact, :phone],
       :fax => [:site_contact, :fax]}
    end
  end
end
