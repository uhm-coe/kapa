module Kapa::FacultyAwardsControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @awards = Kapa::FacultyAward.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def new
    @person = Kapa::Person.find(params[:id])
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @award = Kapa::FacultyAward.new(award_params)
    @award.attributes = award_params
    @award.person = @person

    unless @award.save
      flash[:danger] = error_message_for(@award)
      redirect_to new_kapa_faculty_award_path(:id => @person) and return false
    end

    flash[:success] = "Award was successfully created."
    redirect_to kapa_faculty_award_path(:id => @award)
  end

  def show
    @award = Kapa::FacultyAward.find(params[:id])
    @award_ext = @award.ext
    @person = @award.person
  end

  def update
    @award = Kapa::FacultyAward.find(params[:id])
    @award.attributes = award_params
    @award.update_serialized_attributes!(:_ext, params[:award_ext]) if params[:award_ext].present?

    unless @award.save
      flash[:danger] = @award.errors.full_messages.join(", ")
      redirect_to kapa_faculty_award_path(:id => @award) and return false
    end

    flash[:success] = "Award was successfully updated."
    redirect_to kapa_faculty_award_path(:id => @award)
  end

  def destroy
    @award = Kapa::FacultyAward.find(params[:id])
    unless @award.destroy
      flash[:danger] = error_message_for(@award)
      redirect_to kapa_faculty_award_path(:id => @award) and return false
    end
    flash[:success] = "Award was successfully deleted."
    redirect_to kapa_person_path(:id => @award.person)
  end

  def export
    @filter = filter
    send_data Kapa::FacultyAward.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "faculty_awards_#{@filter.date_start.to_s}.csv"
  end

  private
  def award_params
    params.require(:award).permit(:person_id, :dept, :yml, :xml, :name, :award_date, :affiliation, :description, :url, :context, :public, :image)
  end
end