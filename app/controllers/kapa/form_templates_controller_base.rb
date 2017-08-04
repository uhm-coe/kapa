module Kapa::FormTemplatesControllerBase
  extend ActiveSupport::Concern

  def show
    @form_template = Kapa::FormTemplate.find(params[:id])
    @form_template_ext = @form_template.ext
    @form_fields = @form_template.form_fields
  end

  def new
    @form_template = Kapa::FormTemplate.new
  end

  def update
    @form_template = Kapa::FormTemplate.find(params[:id])
    @form_template.attributes = form_template_params
    @form_template.update_serialized_attributes!(:_ext, params[:form_template_ext]) if params[:form_template_ext].present?
    if @form_template.save
      flash[:success] = "Rubric was successfully updated."
    else
      flash[:danger] = @form_template.errors.full_messages.join(", ")
    end
    redirect_to kapa_form_template_path(:id => @form_template)
  end

  def create
    @form_template = Kapa::FormTemplate.new
    @form_template.attributes= form_template_params
    unless @form_template.save
      flash[:danger] = @form_template.errors.full_messages.join(", ")
      redirect_to new_kapa_form_template_path and return false
    end
    flash[:success] = "Rubric was successfully created."
    redirect_to kapa_form_template_path(:id => @form_template)
  end

  def destroy
    @form_template = Kapa::FormTemplate.find(params[:id])
    unless @form_template.form_fields.blank?
      flash[:danger] = "Rubric can not be deleted since it contains one or more criteria."
      redirect_to kapa_form_template_path(:id => @form_template) and return false
    end
    unless @form_template.destroy
      flash[:danger] = @form_template.errors.full_messages.join(", ")
      redirect_to kapa_form_template_path(:id => @form_template) and return false
    end
    flash[:success] = "Rubric was successfully deleted."
    redirect_to kapa_form_templates_path
  end

  def index
    @filter = filter
    @form_templates = Kapa::FormTemplate.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  private
  def form_template_params
    params.require(:form_template).permit(:title, :type, :dept, :reference_url, :note, :start_term_id, :end_term_id, :program=>[], :course=>[], :transition_point=>[])
  end
end
