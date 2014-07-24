class Contact < ApplicationModel
  belongs_to :entity, :polymorphic => true
  validates_uniqueness_of :entity_id, :scope => :entity_type, :on => :create, :message => "is already used."
  
  def format
    self.attributes().each_pair do |k, v|
      if v
        self.[]=(k , v.gsub(/\D/, "")) if k =~ /(phone$)/
        self.[]=(k , v.to_s.split(' ').map {|w| w.capitalize }.join(' ')) if k =~ /(street$)|(city$)/
        self.[]=(k , v.to_s.upcase) if k =~ /(state$)/
      end
    end
  end
  
  def email_alt
    email unless email =~ /^[A-Z0-9_%+-]+@hawaii.edu$/i
  end  
end
