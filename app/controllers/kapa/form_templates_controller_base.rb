module Kapa::FormTemplatesControllerBase
  extend ActiveSupport::Concern

  def show
    @form_template = Kapa::FormTemplate.find(params[:id])
    @form_template_ext = @form_template.ext
    @form_template_fields = @form_template.form_template_fields
    @field_selections = Rails.configuration.form_helpers.select {|helper| 
      #Exclude the following form helpers
      %w{password_field
         color_field
         search_field
         person_select 
         text_template_select
         program_select
         history_select
         model_select
         user_select 
         check_box
         radio_button 
         static
      }.exclude?(helper.to_s)  
    }
  end

  def new
    @form_template = Kapa::FormTemplate.new
  end

  def update
    @form_template = Kapa::FormTemplate.find(params[:id])
    @form_template.attributes = form_template_params
    @form_template.update_serialized_attributes!(:_ext, params[:form_template_ext]) if params[:form_template_ext].present?
    if @form_template.save
      flash[:notice] = "Form Template was successfully updated."
    else
      flash[:alert] = @form_template.errors.full_messages.join(", ")
    end
    redirect_to kapa_form_template_path(:id => @form_template)
  end

  def create
    @form_template = Kapa::FormTemplate.new
    @form_template.attributes= form_template_params
    unless @form_template.save
      flash[:alert] = @form_template.errors.full_messages.join(", ")
      redirect_to new_kapa_form_template_path and return false
    end
    flash[:notice] = "Form Template was successfully created."
    redirect_to kapa_form_template_path(:id => @form_template)
  end

  def destroy
    @form_template = Kapa::FormTemplate.find(params[:id])
    unless @form_template.form_template_fields.blank?
      flash[:alert] = "Form Template can not be deleted since it contains one or more fields."
      redirect_to kapa_form_template_path(:id => @form_template) and return false
    end
    unless @form_template.destroy
      flash[:alert] = @form_template.errors.full_messages.join(", ")
      redirect_to kapa_form_template_path(:id => @form_template) and return false
    end
    flash[:notice] = "Form Template was successfully deleted."
    redirect_to kapa_form_templates_path
  end

  def index
    @filter = filter
    @form_templates = Kapa::FormTemplate.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::FormTemplate.to_table(:as => :csv, :filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "form_templates.csv"
  end

  private
  def form_template_params
    params.require(:form_template).permit(:title, :type, :reference_url, :note, :attachment, :template_path, :start_term, :end_term, :dept, :depts => [])
  end
end
