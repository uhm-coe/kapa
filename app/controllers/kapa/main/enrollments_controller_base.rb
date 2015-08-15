module Kapa::Main::EnrollmentsControllerBase
  extend ActiveSupport::Concern

  def show
    @enrollment = Kapa::Enrollment.find(params[:id])
    @curriculum = @enrollment.curriculum
    @person = @curriculum.person
    @person.details(self)
  end

  def new
    @curriculum = Kapa::Curriculum.find(params[:id])
    @person = @curriculum.person
    @person.details(self)
    @enrollment = @curriculum.enrollments.build(:term_id => Kapa::Term.current_term.id, :curriculum_id => params[:id])
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @curriculum = @person.curriculums.find(params[:enrollment][:curriculum_id])

    @enrollment = @curriculum.enrollments.build(enrollment_params)
    @enrollment.dept = @current_user.primary_dept
    unless @enrollment.save
      flash[:danger] = @enrollment.errors.full_messages.join(", ")
      redirect_to new_kapa_main_enrollment_path(:id => @curriculum) and return false
    end
    flash[:success] = "Enrollment was successfully created."
    redirect_to kapa_main_enrollment_path(:id => @enrollment)
  end

  def update
    @enrollment = Kapa::Enrollment.find(params[:id])
    @enrollment.attributes = enrollment_params

    if @enrollment.save
      flash[:success] = "Enrollment was successfully updated."
    else
      flash[:danger] = @enrollment.errors.full_messages.join(", ")
    end
    redirect_to kapa_main_enrollment_path(:id => @enrollment)
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
      PracticumAssignment.delete_all(["practicum_placement_id IN (SELECT id FROM practicum_placements WHERE term_id = ?)", params[:filter][:term_id]])
      Kapa::PracticumPlacement.delete_all(["term_id = ?", params[:filter][:term_id]])
    end

    CSV.new(import_file, :headers => true).each do |row|
      id_number = row["id_number"] ? row["id_number"] : "00000000"
      person = Kapa::Person.lookup(id_number, :verified => true)

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
        placement.user_primary = Kapa::User.find_by_uid(row["coordinator_1_uid"])
        placement.user_secondary = Kapa::User.find_by_uid(row["coordinator_2_uid"])
        placement.uid = row["group"]
        placement.save

        3.times do |i|
          key = "a#{i + 1}"
          unless row["#{key}_site_code"].blank?
            assignment = placement.practicum_assignments.build(:assignment_type => "mentor")
            assignment.content_area = row["#{key}_content_area"]
            assignment.payment = row["#{key}_payment"]
            assignment.practicum_site = Kapa::PracticumSite.find_by_code(row["#{key}_site_code"])
            assignment.person_id = row["#{key}_mentor_person_id"]
            assignment.user_primary = Kapa::User.find_by_uid(row["#{key}_supervisor_1_uid"])
            assignment.user_secondary = Kapa::User.find_by_uid(row["#{key}_supervisor_2_uid"])
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
    @enrollments = Kapa::Enrollment.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{@filter.inspect}"
    send_data Kapa::Enrollment.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "enrollments_#{Kapa::Term.find(@filter.term_id).description if @filter.term_id.present?}_#{Date.today}.csv"
  end

  private
  def enrollment_params
    params.require(:enrollment).permit(:term_id, :sequence, :category, :status, :dept, :user_primary_id,
                                       :user_secondary_id, :note, :curriculum_id)
  end

end
