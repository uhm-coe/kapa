module Kapa::FacultyPublicationsControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @publications = Kapa::FacultyPublication.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def show
    @publication = Kapa::FacultyPublication.find(params[:id])
    @publication_ext = @publication.ext
    @authors = @publication.authors_ordered
    @person = @publication.person
  end

  def new
    @person = Kapa::Person.find(params[:id])
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @publication = @person.faculty_publications.build(publication_params)
    @publication.attributes = publication_params
    @publication.parse(params[:publication][:bibtex]) if params[:publication][:bibtex]

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
    if params[:author] && params[:author][:order]
      params[:author][:order].each do |id, seq|
        author = @publication.authors.find(id)
        author.update(:sequence => seq) unless author.nil?
      end
      flash[:success] = "Author order was successfully updated."
      redirect_to kapa_faculty_publication_path(:id => @publication) and return true

    # Otherwise, update publication attributes
    else
      @publication.attributes = publication_params
      @publication.update_serialized_attributes!(:_ext, params[:publication_ext]) if params[:publication_ext].present?

      unless @publication.save
        flash[:danger] = @publication.errors.full_messages.join(", ")
        redirect_to kapa_faculty_publication_path(:id => @publication) and return false
      end

      if @publication.authors.empty?
        flash[:success] = "Publication was successfully updated. Please assign authors to this publication."
        redirect_to kapa_faculty_publication_path(:id => @publication, :anchor => "author") and return true
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
    redirect_to kapa_person_path(:id => @publication.person)
  end

  def export
    @filter = filter
    send_data Kapa::FacultyPublication.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "faculty_publications_#{@filter.date_start.to_s}.csv"
  end

  private
  def publication_params
    params.require(:publication).permit(:person_id, :dept, :pages, :abstract, :published_date, :location, :publisher, :type, :keyword, :venue, :vol, :num_of_vol, :creator, :title, :month, :year, :document_identifier, :editor, :book_title, :book_chapter, :featured, :organization, :edition, :document_location, :research_location, :institution, :thumbnail, :bibtex)
  end
end
