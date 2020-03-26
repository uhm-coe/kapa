module Kapa::FormTemplateFieldsControllerBase
  extend ActiveSupport::Concern

  def update
    @form_template_field = Kapa::FormTemplateField.find(params[:id])
    @form_template_field.attributes = form_template_field_params
    @form_template_field.update_serialized_attributes(:_ext, params[:form_template_field_ext]) if params[:form_template_field_ext].present?

    if @form_template_field.save
      flash[:notice] = "Field was successfully updated."
    else
      flash[:alert] = @form_template_field.errors.full_messages.join(", ")
    end
    redirect_to kapa_form_template_path(:id => @form_template_field.form_template, :anchor => params[:anchor], :label_panel => params[:label_panel])
  end

  def create
    @form_template_field = Kapa::FormTemplateField.new(:form_template_id => params[:id])
    @form_template_field.attributes = form_template_field_params

    if @form_template_field.save
      flash[:notice] = "Field was successfully created."
    else
      flash[:alert] = @form_template_field.errors.full_messages.join(", ")
    end
    redirect_to kapa_form_template_path(:id => @form_template_field.form_template, :anchor => params[:anchor], :label_panel => @form_template_field.id)
  end

  def destroy
    @form_template_field = Kapa::FormTemplateField.find(params[:id])
    unless @form_template_field.form_fields.blank?
      flash[:warning] = "Field cannot be deleted since there are associated data entries."
      redirect_to kapa_form_template_path(:id => @form_template_field.form_template, :anchor => params[:anchor]) and return false
    end
    unless @form_template_field.destroy
      flash[:alert] = @form_template_field.errors.full_messages.join(", ")
      redirect_to kapa_form_template_path(:id => @form_template_field.form_template, :anchor => params[:anchor]) and return false
    end
    flash[:notice] = "Field was successfully deleted."
    redirect_to kapa_form_template_path(:id => @form_template_field.form_template, :anchor => params[:anchor])
  end

  private
  def form_template_field_params
    params.require(:form_template_field).permit(:form_template_id, :label, :label_desc, :category, :type, :type_option, :sequence)
  end
end
