module Kapa::Practicum::SitesControllerBase
  extend ActiveSupport::Concern

  def show
    @practicum_site = Kapa::PracticumSite.find(params[:id])
    @site_contact = @practicum_site.site_contact
    @mentors = Kapa::Person.eager_load(:contact).where("id in (SELECT distinct mentor_person_id FROM practicum_placements)").order("persons.last_name, persons.first_name")
    @practicum_placements = @practicum_site.practicum_placements.eager_load(:term).order("terms.sequence DESC")
  end

  def new
    @practicum_site = Kapa::PracticumSite.new :district => "Private"
  end

  def create
    @practicum_site = Kapa::PracticumSite.new practicum_site_params
    unless @practicum_site.save
      flash[:danger] = @practicum_site.errors.full_messages.join(", ")
      redirect_to new_kapa_practicum_site_path and return false
    end
    flash[:success] = "Site was sccessfully created."
    redirect_to kapa_practicum_site_path(:id => @practicum_site)
  end

  def update
    @practicum_site = Kapa::PracticumSite.find(params[:id])
    @practicum_site.attributes= practicum_site_params
    @practicum_site.serialize(:site_contact, params[:site_contact]) if not params[:site_contact].blank?

    if @practicum_site.save
      flash[:success] = "Site info was successfully updated."
    else
      flash[:danger] = "Failed to update site profile."
    end
    redirect_to kapa_practicum_site_path(:id => @practicum_site, :focus => params[:focus])
  end

  def destroy
    @practicum_site = Kapa::PracticumSite.find(params[:id])

    if @practicum_site.destroy
      flash[:success] = "Site was successfully deleted."
    else
      flash[:danger] = "Failed to delete site."
    end
    redirect_to kapa_practicum_sites_path
  end

  def import
    # Do error checking of the file
    unless params[:data].present? && params[:data][:import_file].present?
      flash[:warning] = "Please specify the file you are importing."
      redirect_to(:action => :index) and return false
    end
    import_file = params[:data][:import_file]

    CSV.new(import_file.tempfile, :headers => true).each do |row|
      if row["code"].blank?
        flash[:danger] = "No site code defined."
        redirect_to(:action => :index) and return false
      end
      site = Kapa::PracticumSite.find_or_create_by_code(row["code"])
      site.district = row["district"]
      site.level_from = row["level_from"]
      site.level_to = row["level_to"]
      site.category = row["category"]
      site.name = row["name"]
      site.name_short = row["name_short"]
      site.area = row["area"]
      site.area_group = row["area_group"]
      site.url = row["url"]
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
    @practicum_sites = Kapa::PracticumSite.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{filter.inspect}"
    send_data Kapa::PracticumSite.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "sites.csv"
  end

  private
  def practicum_site_params
    params.require(:practicum_site).permit(:name, :name_short, :code, :district, :area, :area_group, :level_from, :level_to)
  end
end
