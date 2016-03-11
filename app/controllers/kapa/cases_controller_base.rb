module Kapa::CasesControllerBase
  extend ActiveSupport::Concern

  def show
    @case = Kapa::Case.find(params[:id])
    @person_references = @case.person_references
    @case_ext = @case.deserialize(:_ext, :as => OpenStruct)
    @case_actions = @case.case_actions.order("action_date DESC, id DESC")
    @person = @case.person
    @curriculums = @person.curriculums
    @documents = []
    @documents += @case.files
    @documents += @case.forms
    @attachable_type = @case.class.name
    @attachable_id = @case.id
  end

  def update
    if params[:case]
      @case = Kapa::Case.find(params[:id])
      @case.attributes = case_params
      @case.update_serialized_attributes(:_ext, params[:case_ext]) if params[:case_ext]

      unless @case.save
        flash[:danger] = @case.errors.full_messages.join(", ")
        redirect_to kapa_case_path(:id => @case, :anchor => params[:anchor]) and return false
      end
    end

    flash[:success] = "Case was successfully updated."
    redirect_to kapa_case_path(:id => @case, :anchor => params[:anchor])
  end

  def new
    @person = Kapa::Person.find(params[:id])
    @case = @person.cases.build(:term_id => Kapa::Term.current_term.id)
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @case = @person.cases.build(case_params)
    @case.dept = @current_user.primary_dept
    @case.active = true
    unless @case.save
      flash[:danger] = @case.errors.full_messages.join(", ")
      redirect_to new_kapa_case_path(:id => @person) and return false
    end
    flash[:success] = "Case was successfully created."
    redirect_to kapa_case_path(:id => @case)
  end

  def index
    @filter = filter
    @cases = Kapa::Case.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::Case.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "#{@filter.name}_#{Kapa::Term.find(@filter.term_id).description if @filter.term_id.present?}.csv"
  end

  private
  def case_params
    params.require(:case).permit(:person_id, :term_id, :curriculum_id, :form_id, :type, :status, :category, :priority, :location, :location_detail, :incident_datetime, :investigator, :dept, :note, :user_ids => [])
  end

end
