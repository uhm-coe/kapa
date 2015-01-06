class Admin::RestrictedReportsController < Admin::BaseController

  def index
    @filter = transition_point_filter
    order = "persons.last_name, persons.first_name"
    @transition_points = TransitionPoint.paginate(:page => params[:page], :per_page => 20, :include => [{:curriculum => [:person, :program]}, :last_transition_action], :conditions => @filter.conditions, :order => order)
  end

  def export
    if params[:key_file].blank?
      flash[:warning] = "Please select your key file."
      redirect_to error_path
      return false
    end

    @key_file = params[:key_file].read
    #Verify the key file and passphrase work
    begin
      test_person = Person.find(:first, :conditions => "ssn_crypted is not null")
      Person.decrypt(test_person.ssn_crypted, @key_file)
    rescue StandardError
      flash[:danger] = $ERROR_INFO
      redirect_to error_path
      return false
    end

    @filter = transition_point_filter
    order = "persons.last_name, persons.first_name"
    transition_points = TransitionPoint.find(:all, :include => [{:curriculum => [:person, :program]}, :last_transition_action], :conditions => @filter.conditions, :order => order)

    csv_string = CSV.generate do |csv|
      csv << column_names
      transition_points.each do |c|
        csv << row(c)
      end
    end

    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "persons_#{@filter.type}.csv"
  end

  private
  def transition_point_filter
    f = filter
    f.append_condition("transition_points.academic_period >= ?", :academic_period_first)
    f.append_condition("transition_points.academic_period <= ?", :academic_period_last)
    f.append_condition "transition_points.status = ?", :status
    f.append_condition "transition_points.type = ?", :type
    f.append_condition "programs.code = ?", :program
    f.append_condition "curriculums.distribution = ?", :distribution
    f.append_condition "curriculums.major_primary = ?", :major
    f.append_program_condition("programs.code in (?)", :depts => @current_user.depts) unless @current_user.manage?
    return f
  end

  def column_names
    [:id_number,
     :last_name,
     :first_name,
     :email,
     :email_alt,
     :ssn,
     :ssn_agreement,
     :cur_street,
     :cur_city,
     :cur_state,
     :cur_postal_code,
     :cur_phone,
     :program_desc,
     :track_desc,
     :major_primary_desc,
     :major_secondary_desc,
     :distribution_desc,
     :second_degree,
     :academic_period_desc,
     :status,
     :status_desc,
     :action,
     :action_desc,
     :action_date]
  end

  def row(c)
    [rsend(c, :curriculum, :person, :id_number),
     rsend(c, :curriculum, :person, :last_name),
     rsend(c, :curriculum, :person, :first_name),
     rsend(c, :curriculum, :person, :email),
     rsend(c, :curriculum, :person, :contact, :email_alt),
     c.curriculum.person.ssn_agreement == "Y" ? Person.decrypt(c.curriculum.person.ssn_crypted, @key_file) : nil,
     rsend(c, :curriculum, :person, :ssn_agreement),
     rsend(c, :curriculum, :person, :contact, :cur_street),
     rsend(c, :curriculum, :person, :contact, :cur_city),
     rsend(c, :curriculum, :person, :contact, :cur_state),
     rsend(c, :curriculum, :person, :contact, :cur_postal_code),
     rsend(c, :curriculum, :person, :contact, :cur_phone),
     rsend(c, :curriculum, :program, :description),
     rsend(c, :curriculum, :track_desc),
     rsend(c, :curriculum, :major_primary_desc),
     rsend(c, :curriculum, :major_secondary_desc),
     rsend(c, :curriculum, :distribution_desc),
     rsend(c, :curriculum, :second_degree),
     rsend(c, :academic_period_desc),
     rsend(c, :status),
     rsend(c, :status_desc),
     rsend(c, :last_transition_action, :action),
     rsend(c, :last_transition_action, :action_desc),
     rsend(c, :last_transition_action, :action_date)]
  end

end
