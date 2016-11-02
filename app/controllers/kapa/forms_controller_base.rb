module Kapa::FormsControllerBase
  extend ActiveSupport::Concern

  def show
    @form = Kapa::Form.find params[:id]
    @form_ext = @form.ext
    @person = @form.person
    @person_ext = @person.ext
    @title = @form.type_desc
    render :layout => "/kapa/layouts/document"
  end

  def update
    @form = Kapa::Form.find params[:id]
    @person = @form.person
    @form.attributes = form_param
    @form.update_serialized_attributes!(:_ext, params[:form_ext]) if params[:form_ext].present?
    params.permit!.to_h.each_pair do |k, v|
      unless k =~ /(utf8)|(_method)|(authenticity_token)|(form)|(commit)|(controller)|(action)|(id)/
        @form.serialize(k.to_sym, v)
      end
    end

    if @form.save
      flash[:success] = "Form was successfully updated."
    else
      flash[:danger] = error_message_for(@form)
    end
    redirect_to kapa_form_path(:id => @form)
  end

  def create
    @form = Kapa::Form.new(form_param)
    @form.dept = [@current_user.primary_dept]

    unless @form.save
      flash[:danger] = error_message_for(@form)
      redirect_to(kapa_error_path) and return false
    end

    flash[:success] = "Form was successfully created."
    redirect_to params[:return_path]
  end

  def destroy
    @form = Kapa::Form.find params[:id]
    unless @form.destroy
      flash[:danger] = error_message_for(@form)
      redirect_to kapa_form_path(:id => @form) and return false
    end
    flash[:success] = "Form was successfully deleted."
    redirect_to kapa_person_path(:id => @form.person, :anchor => :document)
  end

  def index
    @filter = filter
    @forms = Kapa::Form.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::Form.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "forms_#{filter.type}.csv"
  end

  private
  def form_param
    params.require(:form).permit(:type, :person_id, :attachable_id, :attachable_type, :lock, :note, :public)
  end
end
