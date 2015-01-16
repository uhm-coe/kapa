class Artifact::FormsController < Artifact::BaseController

  def show
    @form = Form.find params[:id]
    @person = @form.person
    @title = @form.type_desc
    render :layout => "artifact"
  end

  def update
    @form = Form.find params[:id]
    @person = @form.person
    #attributes= was not used because I do not want to accidentally delete form.data
    @form.note = params[:form][:note] unless params[:form][:note].blank?
    @form.lock = params[:form][:lock] unless params[:form][:lock].blank?

    if @form.save
      flash[:success] = "Form was updated."
    else
      flash[:danger] = error_message_for(@form)
    end
    redirect_to artifact_form_path(:id => @form)
  end

  def create
    @person = Person.find params[:id]
    @form = @person.forms.build(params[:form])
    @form.dept = @current_user.primary_dept

    unless @form.save
      flash[:danger] = error_message_for(@form)
      redirect_to(error_path) and return false
    end

    flash[:success] = "Form was successfully created."
    params[:return_url][:focus] = params[:focus]
    redirect_to params[:return_url]
  end

  def destroy
    @form = Form.find params[:id]
    unless @form.destroy
      flash[:danger] = error_message_for(@form)
      redirect_to artifact_form_path(:id => @form) and return false
    end
    flash[:success] = "Form was successfully deleted."
    redirect_to main_persons_path(:action => :show, :id => @form.person_id)
  end

  def index
    @filter = form_filter
    @forms = Form.paginate(:page => params[:page], :per_page => 20, :include => :person, :conditions => @filter.conditions, :order => "persons.last_name, persons.first_name")
  end

  def export
    @filter = form_filter
    forms = Form.find :all, :include => [:person => :contact], :conditions => @filter.conditions, :order => "submitted_at desc, persons.last_name, persons.first_name"
    csv_string = CSV.generate do |csv|
      csv << [:id_number,
              :last_name,
              :first_name,
              :ssn,
              :ssn_agreement,
              :cur_street,
              :cur_city,
              :cur_state,
              :cur_postal_code,
              :cur_phone,
              :email,
              :updated,
              :submitted,
              :lock]
      forms.each do |c|
        csv << [rsend(c, :person, :id_number),
                rsend(c, :person, :last_name),
                rsend(c, :person, :first_name),
                rsend(c, :person, :ssn),
                rsend(c, :person, :ssn_agreement),
                rsend(c, :person, :contact, :cur_street),
                rsend(c, :person, :contact, :cur_city),
                rsend(c, :person, :contact, :cur_state),
                rsend(c, :person, :contact, :cur_postal_code),
                rsend(c, :person, :contact, :cur_phone),
                rsend(c, :person, :contact, :email),
                rsend(c, :updated_at),
                rsend(c, :submitted_at),
                rsend(c, :lock)]
      end
    end

    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "forms_#{filter.type}.csv"
  end

  private
  def form_filter
    f = filter
    f.append_condition "forms.term_id = ?", :term_id
    f.append_condition "forms.type = ?", :type
    f.append_depts_condition("forms.public = 'Y' or forms.dept like ?", @current_user.depts) unless @current_user.manage? :artifact
    return f
  end
end
