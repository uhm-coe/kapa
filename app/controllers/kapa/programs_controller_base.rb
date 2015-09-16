module Kapa::ProgramsControllerBase
  extend ActiveSupport::Concern

  def show
    @program = Kapa::Program.find params[:id]
    @program_offers = @program.program_offers
    @available_majors = @program.available_major.to_s.split(/,\s*/)
    @available_distributions = @program.available_distribution.to_s.split(/,\s*/)
    @assessment_rubrics = Kapa::AssessmentRubric.eager_load(:assessment_criterions).where("program like '%#{@program.code}%'")
  end

  def update
    @program = Kapa::Program.find params[:id]
    @program.attributes = program_params

    if @program.save
      flash[:success] = "Program was successfully updated."
    else
      flash[:danger] = @program.errors.full_messages.join(", ")
    end
    redirect_to kapa_program_path(:id => @program)
  end

  def new
    @program = Kapa::Program.new
  end

  def create
    @program = Kapa::Program.new
    @program.attributes = program_params

    unless @program.save
      flash[:danger] = @program.errors.full_messages.join(", ")
      redirect_to new_kapa_program_path and return false
    end
    flash[:success] = "Program was successfully created."
    redirect_to kapa_program_path(:id => @program, :anchor => params[:anchor])
  end

  def destroy
    @program = Kapa::Program.find params[:id]

    @program.program_offers.each do |program_offer|
      unless program_offer.destroy
        flash[:danger] = error_message_for(program_offer)
        redirect_to kapa_program_path(:id => @program) and return false
      end
    end

    unless @program.destroy
      flash[:danger] = error_message_for(@program)
      redirect_to kapa_program_path(:id => @program) and return false
    end
    flash[:success] = "Program was successfully deleted."
    redirect_to kapa_programs_path
  end

  def index
    @filter = filter
    @programs = Kapa::Program.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  private
  def program_params
    params.require(:program).permit(:code, :description, :description_short, :category, :dept, :active, :degree,
                                    :major, :distribution, :track, :available_major => [], :available_distribution => [], :available_track => [])
  end
end
