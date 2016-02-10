module Kapa::FacultyPublicationsAuthorsControllerBase
  extend ActiveSupport::Concern

  def index
  end

  def show
    @author = Kapa::FacultyPublicationsAuthor.find(params[:id])
    @publication = @author.faculty_publication
    @person = @publication.person
  end

  def new
  end

  def create
    @author = Kapa::FacultyPublicationsAuthor.new(author_params_subset(params))
    @publication = Kapa::FacultyPublication.find(params[:faculty_publication_id])
    @publication.authors << @author

    unless @author.save
      flash[:danger] = error_message_for(@author)
      redirect_to kapa_faculty_publication_path(:id => @publication) and return false
    end

    flash[:success] = "Author was successfully created."
    redirect_to kapa_faculty_publication_path(:id => @publication)
  end

  def update
    @author = Kapa::FacultyPublicationsAuthor.find(params[:id])
    @author.attributes = author_params_subset(params)
    @publication = Kapa::FacultyPublication.find(params[:faculty_publication_id])

    unless @author.save
      flash[:danger] = @author.errors.full_messages.join(", ")
      redirect_to kapa_faculty_publication_path(:id => @publication) and return false
    end

    flash[:success] = "Author was successfully updated."
    redirect_to kapa_faculty_publication_path(:id => @publication)
  end

  def destroy
    @author = Kapa::FacultyPublicationsAuthor.find(params[:id])
    @publication = @author.faculty_publication
    unless @author.destroy
      flash[:danger] = error_message_for(@author)
      redirect_to kapa_faculty_publication_path(:id => @publication) and return false
    end
    flash[:success] = "Author was successfully deleted."
    redirect_to kapa_faculty_publication_path(:id => @publication)
  end

  def export
  end

  private
  def author_params
    params.require(:author).permit(:faculty_publication_id, :type, :person_id, :last_name, :first_name, :middle_initial, :sequence, :yml, :xml)
  end

  # Only selects fields relevant to author type.
  # If author is internal, last/first/MI are irrelevant.
  # If author is external, person_id must be nil.
  def author_params_subset(params)
    case params[:author][:type]
      when "internal"
        author_params.slice("type", "person_id")
      when "external"
        author_params.slice("type", "last_name", "first_name", "middle_initial")
    end
  end
end
