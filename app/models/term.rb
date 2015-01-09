class Term < ActiveRecord::Base

  def self.selections(options = {})
    Term.where(:active => 1).order("sequence DESC, code").each do |v|
      selections.push [v.description, v.id]
    end
    return selections
  end

end
