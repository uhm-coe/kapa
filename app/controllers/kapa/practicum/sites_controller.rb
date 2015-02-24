class Kapa::Practicum::SitesController < Kapa::Practicum::BaseController

  def show
    @practicum_site = PracticumSite.find(params[:id])
    @site_contact = @practicum_site.site_contact
    #["id in (SELECT distinct person_id FROM practicum_assignments WHERE practicum_site_id = ?)", params[:id]]
    @mentors = Person.find(:all, :include => [:contact, :practicum_assignments], :conditions => ["practicum_assignments.id is not null and practicum_assignments.practicum_site_id = ?", params[:id]], :order => "persons.last_name, persons.first_name")
    # TODO: Need to change academic_period to term_id
    @practicum_assignments = @practicum_site.practicum_assignments.find(:all, :include => :practicum_placement, :order => "practicum_placements.academic_period DESC")
  end

  def new
    @practicum_site = PracticumSite.new :district => "Private"
  end

  def create
    @practicum_site = PracticumSite.new params[:practicum_site]
    unless @practicum_site.save
      flash[:danger] = @practicum_site.errors.full_messages.join(", ")
      redirect_to new_kapa_practicum_site_path and return false
    end
    flash[:success] = "School was sccessfully created."
    redirect_to kapa_practicum_site_path(:id => @practicum_site)
  end

  def update
    @practicum_site = PracticumSite.find(params[:id])
    @practicum_site.attributes= params[:practicum_site]
    @practicum_site.serialize(:site_contact, params[:site_contact]) if not params[:site_contact].blank?

    if @practicum_site.save
      flash[:success] = "School info was successfully updated."
    else
      flash[:danger] = "Failed to update site profile."
    end
    redirect_to kapa_practicum_site_path(:id => @practicum_site, :focus => params[:focus])
  end

  def import
    import_file = params[:filter][:import_file]
    #Do error checking of the file
    unless import_file
      flash[:warning] = "Please specify the file you are importing!"
      redirect_to(kapa_error_path) and return false
    end

    CSV.new(import_file, :headers => true).each do |row|
      if row["site_code"].blank?
        flash[:danger] = "No site code defined!"
        redirect_to(kapa_error_path) and return false
      end
      site = PracticumSite.find_or_create_by_code(row["site_code"])
      site.island = row["island"]
      site.district = row["district"]
      site.grade_from = row["grade_from"]
      site.grade_to = row["grade_to"]
      site.site_type = row["site_type"]
      site.name = row["name"]
      site.name_short = row["name_short"]
      site.area = row["area"]
      site.area_group = row["area"]
      site.url_home = row["url_home"]
      site_contact = {}
      site_contact[:street] = row["street"]
      site_contact[:city] = row["city"]
      site_contact[:state] = row["state"]
      site_contact[:postal_code] = row["postal_code"]
      site_contact[:phone] = row["phone"]
      site_contact[:fax] = row["fax"]
      site_contact[:principal_last_name] = row["principal_last_name"]
      site_contact[:principal_first_name] = row["principal_first_name"]
      site.serialize(:site_contact, site_contact)
      site.save
    end
    redirect_to(:action => :index)
  end

  def index
    @filter = site_filter
    @practicum_sites = PracticumSite.paginate(:page => params[:page], :per_page => 20, :include => :practicum_assignments, :conditions => @filter.conditions, :order => "name_short")
  end

  def export
    @filter = site_filter
    @practicum_sites = PracticumSite.find(:all, :conditions => @filter.conditions, :order => "name_short")
    csv_string = CSV.generate do |csv|
      csv << table_format.keys
      @practicum_sites.each {|c| csv << table_format(c).values}
    end
    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "sites.csv"
  end

  private
  def site_filter
    f = filter
    f.append_condition "name like ?", :name, :like => true
#    f.append_condition "? between grade_from and grade_to", :grade
    f.append_condition "district = ?", :district
    f.append_condition "area_group = ?", :area_group
    return f
  end

  def table_format(c = nil)
    row = {
      :site_code => rsend(c, :code),
      :island => rsend(c, :island),
      :district => rsend(c, :district),
      :grade_from => rsend(c, :grade_from),
      :grade_to => rsend(c, :grade_to),
      :site_type => rsend(c, :site_type),
      :name =>  rsend(c, :name),
      :name_short => rsend(c, :name_short),
      :area => rsend(c, :area),
      :area_group => rsend(c, :area_group),
      :principal_last_name => rsend(c, :site_contact, :principal_first_name),
      :principal_first_name => rsend(c, :site_contact, :principal_last_name),
      :street => rsend(c, :site_contact, :street),
      :city => rsend(c, :site_contact, :city),
      :state => rsend(c, :site_contact, :state),
      :postal_code => rsend(c, :site_contact, :postal_code),
      :phone => rsend(c, :site_contact, :phone),
      :fax => rsend(c, :site_contact, :fax)
    }
    return row
  end
end
