module Kapa::Document::FormsControllerBase
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
    #attributes= was not used because I do not want to accidentally delete form.data
    @form.note = params[:form][:note] unless params[:form][:note].blank?
    @form.lock = params[:form][:lock] unless params[:form][:lock].blank?

    if @form.save
      flash[:success] = "Form was successfully updated."
    else
      flash[:danger] = error_message_for(@form)
    end
    redirect_to kapa_main_person_path(:id => @person, :artifacts_modal => "show")
  end

  def create
    @person = Kapa::Person.find params[:id]
    @form = @person.forms.build(params[:form])
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
      redirect_to kapa_document_form_path(:id => @form) and return false
    end
    flash[:success] = "Form was successfully deleted."
    redirect_to kapa_main_person_path(:id => @form.person_id)
  end

  def index
    @filter = filter
    @forms = Kapa::Form.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{filter.inspect}"
    send_data Kapa::Form.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "forms_#{filter.type}.csv"
  end
end
