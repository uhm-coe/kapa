class Admin::ProgramsController < Admin::BaseController

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
    redirect_to admin_program_path(:id => @program)
  end

  def new
    @program = Program.new
  end

  def create
    @program = Program.new
    @program.attributes = params[:program]

    unless @program.save
      flash[:danger] = @program.errors.full_messages.join(", ")
      redirect_to new_admin_program_path and return false
    end
    flash[:success] = "Program was successfully created."
    redirect_to admin_program_path(:id => @program, :focus => params[:focus])
  end

  def index
    @filter = filter
    @filter.append_condition "dept like ?", :dept, :like => true
    @filter.append_condition "active = ?", :active
    @programs = Program.paginate(:page => params[:page], :per_page => 20, :conditions => @filter.conditions, :order => "code")
  end
end
