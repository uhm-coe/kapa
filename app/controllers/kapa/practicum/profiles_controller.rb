class Kapa::Practicum::ProfilesController < Kapa::Practicum::BaseController

  def update
    @practicum_profile = PracticumProfile.find(params[:id])
    @practicum_profile.attributes = params[:practicum_profile]

    if @practicum_profile.save
      flash[:success] = "Placement profile record was successfully updated."
    else
      flash[:danger] = error_message_for(@practicum_profile)
    end
    redirect_to :action => :show, :id => @person.id, :focus => params[:focus]
  end

  def index
    @filter = profiles_filter
    # TODO: Remove curriculum_events, doesn't exist anymore
    order = "curriculum_events.term_id, persons.last_name, persons.first_name"
    @curriculum_enrollments = CurriculumEvent.paginate(:page => params[:page], :per_page => 20, :include => [{:person => [:contact, :practicum_profile]}], :conditions => @filter.conditions, :order => order)
  end

  def export
    @filter = profiles_filter
    # TODO: Remove curriculum_events, doesn't exist anymore
    order = "curriculum_events.term_id, persons.last_name, persons.first_name"
    @curriculum_enrollments = CurriculumEvent.find(:all, :include => [{:person => [:contact, :practicum_profile]}], :conditions => @filter.conditions, :order => order)
    csv_string = CSV.generate do |csv|
      csv << table_format.keys
      @curriculum_enrollments.each {|c| csv << table_format(c).values}
    end
    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "placement_candidates_#{@filter.term_desc}.csv"
  end

  private
  def table_format(o = nil)
    row = {
      :id_number => rsend(o, :person, :id_number),
      :last_name => rsend(o, :person, :last_name),
      :first_name => rsend(o, :person, :first_name),
      :ssn => rsend(o, :person, :ssn),
      :ssn_agreement => rsend(o, :person, :ssn_agreement),
      :cur_street => rsend(o, :person, :contact, :cur_street),
      :cur_city => rsend(o, :person, :contact, :cur_city),
      :cur_state => rsend(o, :person, :contact, :cur_state),
      :cur_postal_code => rsend(o, :person, :contact, :cur_postal_code),
      :cur_phone => rsend(o, :person, :contact, :cur_phone),
      :email => rsend(o, :person, :contact, :email),
      :curriculum_enrollment_id => rsend(o, :id),
      :term_admitted => rsend(o, :term_desc),
      :program_desc => rsend(o, :program_desc),
      :major_primary_desc => rsend(o, :major_primary_desc),
      :major_secondary_desc => rsend(o, :major_secondary_desc),
      :distribution_desc => rsend(o, :distribution_desc),
      :second_degree => rsend(o, :second_degree),
      :second_degree => rsend(o, :cohort),

      :bgc => rsend(o, :person, :practicum_profile, :bgc),
      :bgc_date => rsend(o, :person, :practicum_profile, :bgc_date),
      :insurance => rsend(o, :person, :practicum_profile, :insurance),
      :insurance_effective_period => rsend(o, :person, :practicum_profile, :insurance_effective_period),
      :note => rsend(o, :person, :practicum_profile, :note)
    }
    row
  end

  def profiles_filter
    f = filter
    # TODO: Remove curriculum_events, doesn't exist anymore
    f.append_condition "curriculum_events.status <> 'N'"
    f.append_condition "curriculum_events.context = 'enrollment'"
    f.append_condition "curriculum_events.term_id = ?", :term_id
    f.append_condition "curriculum_events.program = ?", :program
    f.append_condition "curriculum_events.major_primary = ?", :major
    f.append_condition "curriculum_events.distribution = ?", :distribution
    f.append_property_condition "curriculum_events.program in (?)", :program, :depts => @current_user.depts
    f.append_property_condition "curriculum_events.major_primary in (?)", :major, :depts => @current_user.depts
    f.append_condition "curriculum_events.cohort = ?", :cohort
    f.append_condition "practicum_profiles.status = ?", :status
    return f
  end
end
