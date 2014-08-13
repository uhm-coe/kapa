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

    unless @program.save
      flash.now[:notice1] = @program.errors.full_messages.join(", ")
      render_notice and return false
    end
    flash[:notice1] = "Program was successfully updated."
    render_notice
  end

  def new
    @program = Program.new
  end

  def create
    @program = Program.new
    @program.attributes = params[:program]

    unless @program.save
      flash.now[:notice1] = @program.errors.full_messages.join(", ")
      render_notice and return false
    end
    flash[:notice1] = "Program was successfully created."
    redirect_to :action => :show, :id => @program, :focus => params[:focus]
  end

  def index
    @filter = filter
    @filter.append_condition "dept like ?", :dept, :like => true
    @filter.append_condition "active = ?", :active
    @programs = Program.paginate(:page => params[:page], :per_page => 20, :conditions => @filter.conditions, :order => "code")
  end
end
