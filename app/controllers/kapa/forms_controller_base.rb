module Kapa::FormsControllerBase
  extend ActiveSupport::Concern

  def show
    @form = Kapa::Form.find params[:id]
    @person = @form.person
    @title = @form.type_desc
    render :layout => "/kapa/layouts/document"
  end

  def update
    @form = Kapa::Form.find params[:id]
    @person = @form.person

    @form.attributes = form_param
    form_data_params(@form.type).each_pair do |k, v|
      @form.serialize(k, v)
    end

    if @form.save
      flash[:success] = "Form was successfully updated."
    else
      flash[:danger] = error_message_for(@form)
    end
    redirect_to kapa_form_path(:id => @form)
  end

  def create
    @person = Kapa::Person.find params[:id]
    @form = @person.forms.build(form_param)
    @form.dept = @current_user.primary_dept

    unless @form.save
      flash[:danger] = error_message_for(@form)
      redirect_to(kapa_error_path) and return false
    end

    flash[:success] = "Form was successfully created."
    redirect_to params[:return_url]
  end

  def destroy
    @form = Kapa::Form.find params[:id]
    unless @form.destroy
      flash[:danger] = error_message_for(@form)
      redirect_to kapa_form_path(:id => @form) and return false
    end
    flash[:success] = "Form was successfully deleted."
    redirect_to kapa_person_path(:id => @form.person_id, :anchor => :document)
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
    params.require(:form).permit(:type, :person_id, :lock, :note)
  end

  def form_data_params(type)
    case type
      when "declaration"
        permitted_params = [:declaration_curriculum, :declaration_background, :declaration_agreement]
      when "admission"
        permitted_params = [:admission_curriculum, :admission_background, :admission_agreement, :admission_essay]
    end
    form_data_params = {}
    permitted_params.each {|k, v| form_data_params[k] = params.require(k).permit! if params[k]}
    return form_data_params
  end
end
