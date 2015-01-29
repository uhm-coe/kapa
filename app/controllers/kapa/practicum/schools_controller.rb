class Kapa::Practicum::SchoolsController < Kapa::Practicum::BaseController

  def show
    @practicum_school = PracticumSchool.find(params[:id])
    @school_contact = @practicum_school.school_contact
    #["id in (SELECT distinct person_id FROM practicum_assignments WHERE practicum_school_id = ?)", params[:id]]
    @mentors = Person.find(:all, :include => [:contact, :practicum_assignments], :conditions => ["practicum_assignments.id is not null and practicum_assignments.practicum_school_id = ?", params[:id]], :order => "persons.last_name, persons.first_name")
    # TODO: Need to change academic_period to term_id
    @practicum_assignments = @practicum_school.practicum_assignments.find(:all, :include => :practicum_placement, :order => "practicum_placements.academic_period DESC")
  end

  def new
    @practicum_school = PracticumSchool.new :district => "Private"
  end

  def create
    @practicum_school = PracticumSchool.new params[:practicum_school]
    unless @practicum_school.save
      flash[:danger] = @practicum_school.errors.full_messages.join(", ")
      redirect_to new_kapa_practicum_school_path and return false
    end
    flash[:success] = "School was sccessfully created."
    redirect_to kapa_practicum_school_path(:id => @practicum_school)
  end

  def update
    @practicum_school = PracticumSchool.find(params[:id])
    @practicum_school.attributes= params[:practicum_school]
    @practicum_school.serialize(:school_contact, params[:school_contact]) if not params[:school_contact].blank?

    if @practicum_school.save
      flash[:success] = "School info was successfully updated."
    else
      flash[:danger] = "Failed to update school profile."
    end
    redirect_to kapa_practicum_school_path(:id => @practicum_school, :focus => params[:focus])
  end

  def import
    import_file = params[:filter][:import_file]
    #Do error checking of the file
    unless import_file
      flash[:warning] = "Please specify the file you are importing!"
      redirect_to(kapa_error_path) and return false
    end

    CSV.new(import_file, :headers => true).each do |row|
      if row["school_code"].blank?
        flash[:danger] = "No school code defined!"
        redirect_to(kapa_error_path) and return false
      end
      school = PracticumSchool.find_or_create_by_code(row["school_code"])
      school.island = row["island"]
      school.district = row["district"]
      school.grade_from = row["grade_from"]
      school.grade_to = row["grade_to"]
      school.school_type = row["school_type"]
      school.name = row["name"]
      school.name_short = row["name_short"]
      school.area = row["area"]
      school.area_group = row["area"]
      school.url_home = row["url_home"]
      school_contact = {}
      school_contact[:street] = row["street"]
      school_contact[:city] = row["city"]
      school_contact[:state] = row["state"]
      school_contact[:postal_code] = row["postal_code"]
      school_contact[:phone] = row["phone"]
      school_contact[:fax] = row["fax"]
      school_contact[:principal_last_name] = row["principal_last_name"]
      school_contact[:principal_first_name] = row["principal_first_name"]
      school.serialize(:school_contact, school_contact)
      school.save
    end
    redirect_to(:action => :index)
  end

  def index
    @filter = school_filter
    @practicum_schools = PracticumSchool.paginate(:page => params[:page], :per_page => 20, :include => :practicum_assignments, :conditions => @filter.conditions, :order => "name_short")
  end

  def export
    @filter = school_filter
    @practicum_schools = PracticumSchool.find(:all, :conditions => @filter.conditions, :order => "name_short")
    csv_string = CSV.generate do |csv|
      csv << table_format.keys
      @practicum_schools.each {|c| csv << table_format(c).values}
    end
    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "schools.csv"
  end

  private
  def school_filter
    f = filter
    f.append_condition "name like ?", :name, :like => true
#    f.append_condition "? between grade_from and grade_to", :grade
    f.append_condition "district = ?", :district
    f.append_condition "area_group = ?", :area_group
    return f
  end

  def table_format(c = nil)
    row = {
      :school_code => rsend(c, :code),
      :island => rsend(c, :island),
      :district => rsend(c, :district),
      :grade_from => rsend(c, :grade_from),
      :grade_to => rsend(c, :grade_to),
      :school_type => rsend(c, :school_type),
      :name =>  rsend(c, :name),
      :name_short => rsend(c, :name_short),
      :area => rsend(c, :area),
      :area_group => rsend(c, :area_group),
      :principal_last_name => rsend(c, :school_contact, :principal_first_name),
      :principal_first_name => rsend(c, :school_contact, :principal_last_name),
      :street => rsend(c, :school_contact, :street),
      :city => rsend(c, :school_contact, :city),
      :state => rsend(c, :school_contact, :state),
      :postal_code => rsend(c, :school_contact, :postal_code),
      :phone => rsend(c, :school_contact, :phone),
      :fax => rsend(c, :school_contact, :fax)
    }
    return row
  end
end
