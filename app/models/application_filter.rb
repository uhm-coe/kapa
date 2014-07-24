class ApplicationFilter < OpenStruct

  def initialize(hash = nil)
    super(hash)
    @conditions = ["(1=1)"]
  end

  def academic_period_desc
    if academic_period
      return ApplicationProperty.lookup_description(:academic_period, academic_period)
    else
      return "N/A"
    end
  end

  def conditions
    if @conditions.length == 1
      @conditions[0]
    else
      @conditions
    end
  end

  def query(sql)
    param_query = @conditions.clone
    param_query[0] = sql.gsub("?", @conditions[0])
    return param_query
  end

  def append_condition(statement, attribute_name = :no_value, options = {})
    if attribute_name == :no_value
      @conditions[0] << " and (#{statement})"
    else
      value = self.send(attribute_name)
      unless value.blank?
        @conditions[0] << " and (#{statement})"
        value = "%#{value}%" if statement.include?("like")
        statement.count("?").times do
          @conditions.push value
        end
      end
    end
  end

  def append_property_condition(statement, name, options)
    keys = ApplicationProperty.keys(name, options)
    @conditions[0] << " and (#{statement.gsub("?", "'#{keys.join("','")}'")})" #unless keys.blank?
  end

  def append_program_condition(statement, options)
    options[:value] = :code if options[:value].nil?
    filter = ApplicationFilter.new
    filter.append_condition("active = 1")
    filter.append_condition("category = '#{options[:category]}'") if options[:category]
    filter.append_depts_condition("dept like ?", options[:depts]) if options[:depts]
    keys = Program.where(filter.conditions).order("sequence DESC, code").collect {|v| v.send(options[:value])}
    @conditions[0] << " and (#{statement.gsub("?", "'#{keys.join("','")}'")})" unless keys.blank?
  end

  def append_availability_condition(statement, object, name)
    available_code = object.send("available_#{name}")
    @conditions[0] << " and (#{statement.gsub("?", "'#{available_code.split(/,\s*/).join("','")}'")})" unless available_code.blank?
  end

  def append_depts_condition(statement, depts)
    Rails.logger.debug "---depts:#{depts.inspect}"
    unless depts.blank?
      @conditions[0] << " and (0=1"
      depts.each {|d|
        Rails.logger.debug "---d:#{d}"
        @conditions[0] << " or #{statement.gsub("?","'%#{d}%'")}"
      }
      @conditions[0] << ")"
    end
  end

end
