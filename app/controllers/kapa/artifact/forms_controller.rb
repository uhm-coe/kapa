class Kapa::Artifact::FormsController < Kapa::Artifact::BaseController

  def show
    @form = Form.find params[:id]
    @person = @form.person
    @title = @form.type_desc
    render :layout => "/kapa/layouts/artifact"
  end

  def update
    @form = Form.find params[:id]
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
    @person = Person.find params[:id]
    @form = @person.forms.build(params[:form])
    @form.dept = @current_user.primary_dept

    unless @form.save
      flash[:danger] = error_message_for(@form)
      redirect_to(kapa_error_path) and return false
    end

    flash[:success] = "Form was successfully created."
    params[:return_url][:artifacts_modal] = "show"
    redirect_to params[:return_url]
  end

  def destroy
    @form = Form.find params[:id]
    unless @form.destroy
      flash[:danger] = error_message_for(@form)
      redirect_to kapa_artifact_form_path(:id => @form) and return false
    end
    flash[:success] = "Form was successfully deleted."
    redirect_to kapa_main_person_path(:id => @form.person_id)
  end

  def index
    @filter = filter
    @forms = Form.search(@filter).order("persons.last_name, persons.first_name").paginate(:page => params[:page])
  end

  def export
    @filter = filter
    logger.debug "----filter: #{filter.inspect}"
    send_data Form.to_csv(@filter),
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "forms_#{filter.type}.csv"
  end

end
