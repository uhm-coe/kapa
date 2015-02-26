class Kapa::Practicum::SitesController < Kapa::Practicum::BaseController

  def show
    @practicum_site = PracticumSite.find(params[:id])
    @site_contact = @practicum_site.site_contact
    @mentors = Person.includes(:contact).where("id in (SELECT distinct person_id FROM practicum_placements)").order("persons.last_name, persons.first_name")
    @practicum_placements = @practicum_site.practicum_placements.includes(:term).order("terms.sequence DESC")
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
    flash[:success] = "Site was sccessfully created."
    redirect_to kapa_practicum_site_path(:id => @practicum_site)
  end

  def update
    @practicum_site = PracticumSite.find(params[:id])
    @practicum_site.attributes= params[:practicum_site]
    @practicum_site.serialize(:site_contact, params[:site_contact]) if not params[:site_contact].blank?

    if @practicum_site.save
      flash[:success] = "Site info was successfully updated."
    else
      flash[:danger] = "Failed to update site profile."
    end
    redirect_to kapa_practicum_site_path(:id => @practicum_site, :focus => params[:focus])
  end

  def destroy
    @practicum_site = PracticumSite.find(params[:id])

    if @practicum_site.destroy
      flash[:success] = "Site was successfully deleted."
    else
      flash[:danger] = "Failed to delete site."
    end
    redirect_to kapa_practicum_sites_path
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
    @filter = filter
    @per_page_selected = @filter.per_page || Rails.configuration.items_per_page
    @practicum_sites = PracticumSite.search(@filter).order("name_short").paginate(:page => params[:page], :per_page => @per_page_selected)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{filter.inspect}"
    send_data PracticumSite.to_csv(@filter),
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "sites.csv"
  end

end
