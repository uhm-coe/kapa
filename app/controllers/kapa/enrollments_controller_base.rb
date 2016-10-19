module Kapa::EnrollmentsControllerBase
  extend ActiveSupport::Concern

  def show
    @enrollment = Kapa::Enrollment.find(params[:id])
    @curriculum = @enrollment.curriculum
    @person = @enrollment.person
    @person_ext = @person.ext
  end

  def new
    @curriculum = Kapa::Curriculum.find(params[:id])
    @person = @curriculum.person
    @enrollment = @curriculum.enrollments.build(:term_id => Kapa::Term.current_term.id, :curriculum_id => params[:id])
    @enrollment_ext = @enrollment.ext
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @curriculum = @person.curriculums.find(params[:enrollment][:curriculum_id])

    @enrollment = @curriculum.enrollments.build(enrollment_params)
    @enrollment.dept = [@current_user.primary_dept]
    unless @enrollment.save
      flash[:danger] = @enrollment.errors.full_messages.join(", ")
      redirect_to new_kapa_enrollment_path(:id => @curriculum) and return false
    end
    flash[:success] = "Enrollment was successfully created."
    redirect_to kapa_enrollment_path(:id => @enrollment)
  end

  def update
    @enrollment = Kapa::Enrollment.find(params[:id])
    @enrollment.attributes = enrollment_params
    @enrollment.update_serialized_attributes!(:_ext, params[:enrollment_ext]) if params[:enrollment_ext].present?

    if @enrollment.save
      flash[:success] = "Enrollment was successfully updated."
    else
      flash[:danger] = @enrollment.errors.full_messages.join(", ")
    end
    redirect_to kapa_enrollment_path(:id => @enrollment)
  end

  def index
    @filter = filter
    @enrollments = Kapa::Enrollment.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::Enrollment.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "enrollments_#{Kapa::Term.find(@filter.term_id).description if @filter.term_id.present?}_#{Date.today}.csv"
  end

  private
  def enrollment_params
    params.require(:enrollment).permit(:term_id, :sequence, :category, :status, :dept,
                                       :note, :curriculum_id, :user_ids => [])
  end

end
