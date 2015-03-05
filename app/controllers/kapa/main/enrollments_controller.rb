class Kapa::Main::EnrollmentsController < Kapa::Main::BaseController

  def show
    @practicum_placement = PracticumPlacement.find(params[:id])
    @practicum_assignments = @practicum_placement.practicum_assignments.where("assignment_type" => 'mentor').order("practicum_assignments.id")
    @practicum_profile = @practicum_placement.practicum_profile
    @practicum_profile_ext = @practicum_profile.ext
    @person = @practicum_profile.person
    @person.details(self)
    @curriculums = @person.curriculums
    @practicum_sites = PracticumSite.select("id, name_short")
    @mentors = Person.includes(:contact).where("id in (SELECT distinct person_id FROM practicum_assignments)").order("persons.last_name, persons.first_name")
  end

  def new
    @person = Person.find(params[:id])
    @person.details(self)
    @practicum_profile = @person.practicum_profile ||= @person.create_practicum_profile
    @practicum_placement = @practicum_profile.practicum_placements.build(:term_id => Term.current_term.id)
    @curriculums = @person.curriculums
  end

  def create
    @person = Person.find(params[:id])
    @practicum_profile = @person.practicum_profile
    @practicum_profile.attributes = params[:practicum_profile]
    @practicum_placement = @practicum_profile.practicum_placements.build(params[:practicum_placement])
    unless @practicum_profile.save and @practicum_placement.save
      flash[:danger] = error_message_for(@practicum_profile, @practicum_placement)
      redirect_to new_kapa_practicum_placement_path and return false
    end
    flash[:success] = "Placement record was successfully created."
    redirect_to kapa_practicum_placement_path(:id => @practicum_placement)
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
    redirect_to kapa_practicum_placement_path(:id => @practicum_placement)
  end

  def destroy
    @practicum_placement = PracticumPlacement.find(params[:id])
    unless @practicum_placement.destroy
      flash[:danger] = error_message_for(@practicum_placement)
      redirect_to kapa_practicum_placement_path(:id => @practicum_placement) and return false
    end
    flash[:success] = "Placement record successfully deleted."
    redirect_to kapa_main_person_path(:id => @practicum_placement.person_id, :focus => :practicum)
  end

  # TODO
  def import
    @filter = placement_filter
    import_file = params[:data][:import_file].read if params[:data]
    #Do error checking of the file
    unless import_file
      flash[:danger] = "Please specify the file you are importing!"
      redirect_to(kapa_error_path) and return false
    end

    if params[:data][:delete] == "Y"
      PracticumAssignment.delete_all(["practicum_placement_id IN (SELECT id FROM practicum_placements WHERE term_id = ?)",  params[:filter][:term_id]])
      PracticumPlacement.delete_all(["term_id = ?",  params[:filter][:term_id]])
    end

    CSV.new(import_file, :headers => true).each do |row|
      id_number = row["id_number"] ? row["id_number"] : "00000000"
      person = Person.lookup(id_number, :verified => true)

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

        placement = practicum_profile.practicum_placements.find_by_term_id(params[:filter][:term_id])
        if placement
          logger.debug "Record matched! #{placement.id}"
          placement.practicum_assignments.clear
        else
          logger.debug "No match! Creating a new one."
          placement = practicum_profile.practicum_placements.build(:term_id => params[:filter][:term_id], :dept => @current_user.primary_dept)
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
          unless row["#{key}_site_code"].blank?
            assignment = placement.practicum_assignments.build(:assignment_type => "mentor")
            assignment.content_area = row["#{key}_content_area"]
            assignment.payment = row["#{key}_payment"]
            assignment.practicum_site = PracticumSite.find_by_code(row["#{key}_site_code"])
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
    @filter = filter
    @per_page_selected = @filter.per_page || Rails.configuration.items_per_page
    @enrollments = Enrollment.search(@filter).order("persons.last_name, persons.first_name").paginate(:page => params[:page], :per_page => @per_page_selected)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{@filter.inspect}"
    send_data Enrollment.to_csv(@filter),
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "enrollments_#{Term.find(@filter.term_id).description if @filter.term_id.present?}_#{Date.today}.csv"
  end

end
