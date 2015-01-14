class Practicum::PlacementsController < Practicum::BaseController

  def show
    @practicum_placement = PracticumPlacement.find(params[:id])
    @practicum_assignments = @practicum_placement.practicum_assignments.find(:all, :conditions => "assignment_type = 'mentor'", :order => "practicum_assignments.id")
    @practicum_profile = @practicum_placement.practicum_profile
    @practicum_profile_ext = @practicum_profile.ext
    @person = @practicum_profile.person
    @person.details(self)
    @curriculums = @person.curriculums
    @practicum_schools = PracticumSchool.find(:all, :select => "id, name_short")
    @mentors = Person.find(:all, :include => :contact, :conditions => "id in (SELECT distinct person_id FROM practicum_assignments)", :order => "persons.last_name, persons.first_name")
  end

  def new
    @person = Person.find(params[:id])
    @person.details(self)
    @practicum_profile = @person.practicum_profile ||= @person.create_practicum_profile
    # TODO: Change to term_id
    @practicum_placement = @practicum_profile.practicum_placements.build(:academic_period => current_academic_period)
    @curriculums = @person.curriculums
  end

  def create
    @person = Person.find(params[:id])
    @practicum_profile = @person.practicum_profile
    @practicum_profile.attributes = params[:practicum_profile]
    @practicum_placement = @practicum_profile.practicum_placements.build(params[:practicum_placement])
    unless @practicum_profile.save and @practicum_placement.save
      flash[:danger] = error_message_for(@practicum_profile, @practicum_placement)
      redirect_to new_practicum_placement_path and return false
    end
    flash[:success] = "Placement record was successfully created."
    redirect_to practicum_placement_path(:id => @practicum_placement)
  end

  def update
    @practicum_placement = PracticumPlacement.find(params[:id])
    @practicum_placement.attributes = params[:practicum_placement]
    @practicum_profile = @practicum_placement.practicum_profile
    @practicum_profile.attributes = params[:practicum_profile]
    @practicum_profile.update_serialized_attributes(:_ext, params[:practicum_profile_ext])

    if @practicum_placement.save and @practicum_profile.save
      flash[:success] = "Placement record was successfully updated."
    else
      flash[:danger] = error_message_for(@practicum_placement, @practicum_profile)
    end
    redirect_to practicum_placement_path(:id => @practicum_placement)
  end

  def destroy
    @practicum_placement = PracticumPlacement.find(params[:id])
    unless @practicum_placement.destroy
      flash[:danger] = error_message_for(@practicum_placement)
      redirect_to practicum_placement_path(:id => @practicum_placement) and return false
    end
    flash[:success] = "Placement record successfully deleted."
    redirect_to main_person_path(:id => @practicum_placement.person_id, :focus => :practicum)
  end

  def import
    @filter = placement_filter
    import_file = params[:data][:import_file].read if params[:data]
    #Do error checking of the file
    unless import_file
      flash[:danger] = "Please specify the file you are importing!"
      redirect_to(error_path) and return false
    end

    if params[:data][:delete] == "Y"
      PracticumAssignment.delete_all(["practicum_placement_id IN (SELECT id FROM practicum_placements WHERE academic_period = ?)",  params[:filter][:academic_period]])
      PracticumPlacement.delete_all(["academic_period = ?",  params[:filter][:academic_period]])
    end

    CSV.new(import_file, :headers => true).each do |row|
      id_number = row["id_number"] ? row["id_number"] : "00000000"
      person = Person.search(:first, id_number, :verified => true)

      if person
        person.save if person.new_record?
        practicum_profile = person.practicum_profile ||= person.build_practicum_profile
        practicum_profile.curriculum_id = row["curriculum_id"]
        practicum_profile.cohort = row["cohort"]
        practicum_profile.insurance = row["insurance"]
        practicum_profile.insurance_effective_period = row["insurance_effective_period"]
        practicum_profile.bgc = row["bgc"]
        practicum_profile.bgc_date = Date.strptime(row["bgc_date"], '%m/%d/%Y') if row["bgc_date"].present?
        practicum_profile.note = row["note"]
        practicum_profile_ext = Hash.new
        practicum_profile_ext[:off_sequence] = row["off_sequence"]
        practicum_profile_ext[:ite401] = row["ite401"]
        #practicum_profile_ext[:ite401_grade] = row["ite401_grade"]
        practicum_profile_ext[:ite402] = row["ite402"]
        #practicum_profile_ext[:ite402_grade] = row["ite402_grade"]
        practicum_profile_ext[:ite404] = row["ite404"]
        #practicum_profile_ext[:ite404_grade] = row["ite404_grade"]
        practicum_profile_ext[:ite405] = row["ite405"]
        #practicum_profile_ext[:ite405_grade] = row["ite405_grade"]
        practicum_profile.update_serialized_attributes(:_ext, practicum_profile_ext)
        practicum_profile.save

        placement = practicum_profile.practicum_placements.find_by_academic_period(params[:filter][:academic_period])
        if placement
          logger.debug "Record matched! #{placement.id}"
          placement.practicum_assignments.clear
        else
          logger.debug "No match! Creating a new one."
          placement = practicum_profile.practicum_placements.build(:academic_period => params[:filter][:academic_period], :dept => @current_user.primary_dept)
        end

        placement.status = row["status"]
        placement.category = row["category"]
        placement.sequence = row["sequence"]
        placement.mentor_type = row["mentor_type"]
        placement.user_primary = User.find_by_uid(row["coordinator_1_uid"])
        placement.user_secondary = User.find_by_uid(row["coordinator_2_uid"])
        placement.uid = row["group"]
        placement.save

        3.times do |i|
          key = "a#{i + 1}"
          unless row["#{key}_school_code"].blank?
            assignment = placement.practicum_assignments.build(:assignment_type => "mentor")
            assignment.content_area = row["#{key}_content_area"]
            assignment.payment = row["#{key}_payment"]
            assignment.practicum_school = PracticumSchool.find_by_code(row["#{key}_school_code"])
            assignment.person_id = row["#{key}_mentor_person_id"]
            assignment.user_primary = User.find_by_uid(row["#{key}_supervisor_1_uid"])
            assignment.user_secondary = User.find_by_uid(row["#{key}_supervisor_2_uid"])
            assignment.note = row["#{key}_note"]
            assignment.save
          end
        end

      else
        flash[:danger] = "System was not able to find one or more person records!"
        next
      end
    end
    redirect_to(:action => :index)
  end

  def index
    @filter = placement_filter
    @practicum_placements = PracticumPlacement.paginate(:page => params[:page], :per_page => 20, :include => [{:practicum_profile => [{:person => :contact}, {:curriculum => :program}]}, :practicum_assignments], :conditions => @filter.conditions, :order => "persons.last_name, persons.first_name")
  end

  def export
    @filter = placement_filter
    @practicum_placements = PracticumPlacement.find(:all, :include => [{:practicum_profile => [{:person => :contact}, {:curriculum => :program}]}, {:user_primary => :person}, {:user_secondary => :person}, [:practicum_assignments => [:practicum_school, {:person => :contact}, {:user_primary => :person}, {:user_secondary => :person}]]], :conditions => @filter.conditions, :order => "persons.last_name, persons.first_name")
    csv_string = CSV.generate do |csv|
      csv << table_format.collect {|c| c[0]}
      @practicum_placements.each {|o| csv << table_format(o).collect {|c| c[1]}}
    end
    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "placements_#{@filter.academic_period_desc}_#{Date.today}.csv"
  end

  private
  def table_format(o = nil)
    row = [
      [:id_number, rsend(o, :practicum_profile, :person, :id_number)],
      [:last_name, rsend(o, :practicum_profile, :person, :last_name)],
      [:first_name, rsend(o, :practicum_profile, :person, :first_name)],
      [:email, rsend(o, :practicum_profile, :person, :email)],
      [:category, rsend(o, :category)],
      [:sequence, rsend(o, :sequence)],
      [:mentor_type, rsend(o, :mentor_type)]
    ]

    row += [
      [:curriculum_id, rsend(o, :practicum_profile, :curriculum, :id)],
      [:cohort, rsend(o, :practicum_profile, :cohort)],
      [:semester_admitted, rsend(o, :practicum_profile, :curriculum, :academic_period_desc)],
      [:program_desc, rsend(o, :practicum_profile, :curriculum, :program, :description)],
      [:major_primary_desc, rsend(o, :practicum_profile, :curriculum, :major_primary_desc)],
      [:major_secondary_desc, rsend(o, :practicum_profile, :curriculum, :major_secondary_desc)],
      [:distribution_desc, rsend(o, :practicum_profile, :curriculum, :distribution_desc)],
      [:location, rsend(o, :practicum_profile, :curriculum, :location)],
      [:second_degree, rsend(o, :practicum_profile, :curriculum, :second_degree)],

      [:bgc, rsend(o, :practicum_profile, :bgc)],
      [:bgc_date, rsend(o, :practicum_profile, :bgc_date, [:strftime, "%m/%d/%Y"])],
      [:insurance, rsend(o, :practicum_profile, :insurance)],
      [:insurance_effective_period, rsend(o, :practicum_profile, :insurance_effective_period)],
      [:note, rsend(o, :practicum_profile, :note).to_s.gsub(/\n/, "")],
      [:group, rsend(o, :uid)],
      [:off_sequence, rsend(o, :practicum_profile, :ext, :off_sequence)],
      [:ite401, rsend(o, :practicum_profile, :ext, :ite401)],
#      [:ite401_grade, rsend(o, :practicum_profile, :ext, :ite401_grade)],
      [:ite402, rsend(o, :practicum_profile, :ext, :ite402)],
#      [:ite402_grade, rsend(o, :practicum_profile, :ext, :ite402_grade)],
      [:ite404, rsend(o, :practicum_profile, :ext, :ite404)],
#      [:ite404_grade, rsend(o, :practicum_profile, :ext, :ite404_grade)],
      [:ite405, rsend(o, :practicum_profile, :ext, :ite405)],
#      [:ite405_grade, rsend(o, :practicum_profile, :ext, :ite405_grade)],

      [:coordinator_1_uid, rsend(o, :user_primary, :uid)],
      [:coordinator_1_last_name, rsend(o, :user_primary, :person, :last_name)],
      [:coordinator_1_first_name, rsend(o, :user_primary, :person, :first_name)],
      [:coordinator_2_uid, rsend(o, :user_secondary, :uid)],
      [:coordinator_2_last_name, rsend(o, :user_secondary, :person, :last_name)],
      [:coordinator_2_first_name, rsend(o, :user_secondary, :person, :first_name)],

      [:created_at, rsend(o, :created_at)],
      [:updated_at, rsend(o, :updated_at)],
      [:semester, rsend(o, :academic_period_desc)],
      [:status, rsend(o, :status)],
      [:total_mentors, rsend(o, [:practicum_assignments_select, :mentor], :length)]
    ] if @current_user.manage?

    3.times do |i|
      key = "a#{i + 1}"
      row += [
        ["#{key}_mentor_person_id", rsend(o, :practicum_assignments, [:at, i], :person_id)],
        ["#{key}_mentor_last_name", rsend(o, :practicum_assignments, [:at, i], :person, :last_name)],
        ["#{key}_mentor_first_name", rsend(o, :practicum_assignments, [:at, i], :person, :first_name)],
        ["#{key}_mentor_email", rsend(o, :practicum_assignments, [:at, i], :person, :contact, :email)],
        ["#{key}_school_code", rsend(o, :practicum_assignments, [:at, i], :practicum_school, :code)],
        ["#{key}_school_name", rsend(o, :practicum_assignments, [:at, i], :practicum_school, :name_short)],
        ["#{key}_content_area", rsend(o, :practicum_assignments, [:at, i], :content_area)],
        ["#{key}_payment", rsend(o, :practicum_assignments, [:at, i], :payment)],
        ["#{key}_supervisor_1_uid", rsend(o, :practicum_assignments, [:at, i], :user_primary, :uid)],
        ["#{key}_supervisor_1_last_name", rsend(o, :practicum_assignments, [:at, i], :user_primary, :person, :last_name)],
        ["#{key}_supervisor_1_first_name", rsend(o, :practicum_assignments, [:at, i], :user_primary, :person, :first_name)],
        ["#{key}_supervisor_2_uid", rsend(o, :practicum_assignments, [:at, i], :user_secondary, :uid)],
        ["#{key}_supervisor_2_last_name", rsend(o, :practicum_assignments, [:at, i], :user_secondary, :person, :last_name)],
        ["#{key}_supervisor_2_first_name", rsend(o, :practicum_assignments, [:at, i], :user_secondary, :person, :first_name)],
        ["#{key}_note", rsend(o, :practicum_assignments, [:at, i], :note)]
      ]
    end

    row += [
      [:cur_street, rsend(o, :practicum_profile, :person, :contact, :cur_street)],
      [:cur_city, rsend(o, :practicum_profile, :person, :contact, :cur_city)],
      [:cur_state, rsend(o, :practicum_profile, :person, :contact, :cur_state)],
      [:cur_postal_code, rsend(o, :practicum_profile, :person, :contact, :cur_postal_code)],
      [:cur_phone, rsend(o, :practicum_profile, :person, :contact, :cur_phone)],
    ]

    return row
  end

  def placement_filter
    f = filter
    f.append_condition "practicum_placements.academic_period = ?", :academic_period
    if f.program == "NA"
      f.append_condition "programs.code is NULL"
    else
      f.append_condition "programs.code = ?", :program
    end
    f.append_condition "curriculums.distribution = ?", :distribution
    f.append_condition "curriculums.major_primary = ?", :major
    f.append_condition "practicum_placements.status = ?", :status
    f.append_condition "practicum_placements.category = ?", :category
    f.append_condition "practicum_placements.uid = ?", :uid
    if @current_user.access_scope >= 3
      # do nothing
    elsif @current_user.access_scope == 2
      f.append_program_condition("programs.code in (?)", :depts => @current_user.depts)
    elsif @current_user.access_scope == 1
      f.append_condition "#{@current_user.id} in (practicum_placements.user_primary_id, practicum_placements.user_secondary_id)" unless @current_user.manage?
    else
      f.append_condition "1=2"
    end

    return f
  end
end
