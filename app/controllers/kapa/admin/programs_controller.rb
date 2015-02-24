class Kapa::Admin::ProgramsController < Kapa::Admin::BaseController

  def show
    @program = Program.find params[:id]
    @program_offers = @program.program_offers
    @available_majors = @program.available_major.to_s.split(/,\s*/)
    @available_distributions = @program.available_distribution.to_s.split(/,\s*/)
    @assessment_rubrics = AssessmentRubric.includes(:assessment_criterions).where("program like '%#{@program.code}%'")
  end

  def update
    @program = Program.find params[:id]
    @program.attributes = params[:program]

    if @program.save
      flash[:success] = "Program was successfully updated."
    else
      flash[:danger] = @program.errors.full_messages.join(", ")
    end
    redirect_to kapa_admin_program_path(:id => @program)
  end

  def new
    @program = Program.new
  end

  def create
    @program = Program.new
    @program.attributes = params[:program]

    unless @program.save
      flash[:danger] = @program.errors.full_messages.join(", ")
      redirect_to new_kapa_admin_program_path and return false
    end
    flash[:success] = "Program was successfully created."
    redirect_to kapa_admin_program_path(:id => @program, :focus => params[:focus])
  end

  def destroy
    @program = Program.find params[:id]

    @program.program_offers.each do |program_offer|
      unless program_offer.destroy
        flash[:danger] = error_message_for(program_offer)
        redirect_to kapa_admin_program_path(:id => @program) and return false
      end
    end

    unless @program.destroy
      flash[:danger] = error_message_for(@program)
      redirect_to kapa_admin_program_path(:id => @program) and return false
    end
    flash[:success] = "Program was successfully deleted."
    redirect_to kapa_admin_programs_path
  end

  def index
    @filter = filter
    @per_page_selected = @filter.per_page || Rails.configuration.items_per_page
    @programs = Program.search(@filter).order("code").paginate(:page => params[:page], :per_page => @per_page_selected)
  end

end
