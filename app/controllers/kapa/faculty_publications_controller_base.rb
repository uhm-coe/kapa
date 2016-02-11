module Kapa::FacultyPublicationsControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @publications = Kapa::FacultyPublication.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def show
    @publication = Kapa::FacultyPublication.find(params[:id])
    @authors = @publication.authors.order("sequence IS NULL, sequence ASC, id") # NULLs last
    @person = @publication.person
  end

  def new
    @person = Kapa::Person.find(params[:id])
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @publication = Kapa::FacultyPublication.new(publication_params)
    @publication.attributes = publication_params
    @publication.person = @person

    unless @publication.save
      flash[:danger] = error_message_for(@publication)
      redirect_to new_kapa_faculty_publication_path(:id => @person) and return false
    end

    flash[:success] = "Publication was successfully created."
    redirect_to kapa_faculty_publication_path(:id => @publication)
  end

  def update
    @publication = Kapa::FacultyPublication.find(params[:id])

    # If authors sequence form was submitted, update author sequences
    if params[:author][:order]
      params[:author][:order].each do |id, seq|
        author = @publication.authors.find(id)
        author.update(:sequence => seq) unless author.nil?
      end
      flash[:success] = "Author order was successfully updated."
      redirect_to kapa_faculty_publication_path(:id => @publication) and return true

    # Otherwise, update publication attributes
    else
      @publication.attributes = publication_params

      unless @publication.save
        flash[:danger] = @publication.errors.full_messages.join(", ")
        redirect_to kapa_faculty_publication_path(:id => @publication) and return false
      end

      flash[:success] = "Publication was successfully updated."
      redirect_to kapa_faculty_publication_path(:id => @publication)
    end
  end

  def destroy
    @publication = Kapa::FacultyPublication.find(params[:id])
    unless @publication.destroy
      flash[:danger] = error_message_for(@publication)
      redirect_to kapa_faculty_publication_path(:id => @publication) and return false
    end
    flash[:success] = "Publication was successfully deleted."
    redirect_to kapa_person_path(:id => @publication.person_id)
  end

  def export
  end

  private
  def publication_params
    params.require(:publication).permit(:person_id, :dn, :l, :o, :ou, :cn, :objectclass, :dept, :authors, :pubpages, :pubabstract, :pubdate, :publocation, :pubowner, :pubpublisher, :documentauthor, :pubtype, :pubkeyword, :pubvenue, :pubvol, :pubnumofvol, :pubcreator, :pubtitle, :pubmonth, :pubyear, :documentidentifier, :pubcontributor, :pubeditor, :pubbooktitle, :pubthumbnail, :pubbookchapter, :pubisnotfeatured, :puborganization, :pubpdf, :pubedition, :documentlocation, :thumbnail)
  end
end
