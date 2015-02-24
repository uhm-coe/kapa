class PracticumSite < KapaBaseModel
  has_many :practicum_placement

  validates_presence_of :name, :code
  validates_uniqueness_of :code

  def site_contact
    self.deserialize(:site_contact, :as => OpenStruct)
  end

  def grades
    if grade_from != "99"
      "#{grade_from.to_s.sub("0", "K")}-#{grade_to.to_s.sub("0", "K")}"
    else
      "N/A"
    end
  end
end
