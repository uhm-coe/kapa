module Kapa::FormFieldsControllerBase
  extend ActiveSupport::Concern

  def update
    @form_field = Kapa::FormField.find(params[:id])
    @form_field.attributes = form_field_params
    @form_field.update_serialized_attributes!(:_ext, params[:form_field_ext]) if params[:form_field_ext].present?

    if @form_field.save
      flash[:success] = "Field was successfully updated."
    else
      flash[:danger] = @form_field.errors.full_messages.join(", ")
    end
    redirect_to kapa_form_template_path(:id => @form_field.form_template, :anchor => params[:anchor], :label_panel => params[:label_panel])
  end

  def create
    @form_field = Kapa::FormField.new(:form_template_id => params[:id])
    @form_field.attributes = form_field_params

    if @form_field.save
      flash[:success] = "Field was successfully created."
    else
      flash[:danger] = @form_field.errors.full_messages.join(", ")
    end
    redirect_to kapa_form_template_path(:id => @form_field.form_template, :anchor => params[:anchor], :label_panel => @form_field.id)
  end

  def destroy
    @form_field = Kapa::FormField.find(params[:id])
    unless @form_field.form_details.blank?
      flash[:warning] = "Field cannot be deleted since there are associated data entries."
      redirect_to kapa_form_template_path(:id => @form_field.form_template, :anchor => params[:anchor]) and return false
    end
    unless @form_field.destroy
      flash[:danger] = @form_field.errors.full_messages.join(", ")
      redirect_to kapa_form_template_path(:id => @form_field.form_template, :anchor => params[:anchor]) and return false
    end
    flash[:success] = "Field was successfully deleted."
    redirect_to kapa_form_template_path(:id => @form_field.form_template, :anchor => params[:anchor])
  end

  private
  def form_field_params
    params.require(:form_field).permit(:form_template_id, :label, :label_desc, :category, :type, :type_option)
  end
end
