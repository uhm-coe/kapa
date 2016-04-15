module Kapa::CasesControllerBase
  extend ActiveSupport::Concern

  def show
    @case = Kapa::Case.find(params[:id])
    @case_involvements = @case.case_involvements
    @case_ext = @case.deserialize(:_ext, :as => OpenStruct)
    @case_actions = @case.case_actions.eager_load(:user_assignments => {:user => :person}).order("case_actions.action_date DESC, case_actions.id DESC")
    @user_assignments = @case.user_assignments.order("user_assignments.created_at DESC")
    @documents = []
    @documents += @case.files.eager_load(:person)
    @documents += @case.forms.eager_load(:person)
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
    @case = Kapa::Case.new(:reported_at => DateTime.now)
  end

  def create
    @case = Kapa::Case.new(case_params)
    @case.dept = @current_user.primary_dept
    @case.active = true
    unless @case.save
      flash[:danger] = @case.errors.full_messages.join(", ")
      redirect_to new_kapa_case_path and return false
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
    params.require(:case).permit(:person_id, :reported_at, :closed_at, :form_id, :type, :status, :priority, :location, :location_detail, :incident_occurred_at, :referrer, :dept, :note, :category => [], :user_ids => [])
  end

end
