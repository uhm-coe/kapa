module Kapa::FormsControllerBase
  extend ActiveSupport::Concern

  included do
    after_action :ensure_primary_dept_is_included, :only => [:create, :update]
  end

  def show
    @form = Kapa::Form.find params[:id]
    @form_ext = @form.ext
    @form_template = @form.form_template
    @person = @form.person
    @person_ext = @person.ext
    @document_title = @form.document_title
    @document_id = @form.document_id
    @document_date = @form.document_date
    render :layout => "kapa/layouts/document"
  end

  def update
    @form = Kapa::Form.find params[:id]
    @person = @form.person
    @form.attributes = form_param
    @form.update_serialized_attributes(:_ext, params.require(:form_ext).permit!) if params[:form_ext].present?

    #Save ramdom form attributes for complex form templates.
    params.keys.each do |key|
      unless key =~ /(utf8)|(_method)|(authenticity_token)|(form)|(form_ext)|(commit)|(controller)|(action)|(id)/
        @form.serialize(key.to_sym, params.require(key).permit!)
      end
    end

    if @form.save
      flash[:notice] = "Form was successfully updated."
    else
      flash[:alert] = error_message_for(@form)
    end
    redirect_to kapa_form_path(:id => @form)
  end

  def create
    @form = Kapa::Form.new(form_param)

    unless @form.save
      flash[:alert] = error_message_for(@form)
      redirect_to(kapa_error_path) and return false
    end

    flash[:notice] = "Form was successfully created."
    redirect_to params[:return_path]
  end

  def destroy
    @form = Kapa::Form.find params[:id]
    @person = @form.person
    @person_ext = @person.ext
    @document_title = @form.document_title
    @document_id = @form.document_id
    @document_date = @form.document_date

    unless @form.destroy
      flash[:alert] = error_message_for(@form)
      redirect_to kapa_form_path(:id => @form) and return false
    end

    flash[:notice] = "Form was successfully deleted. Please close this tab."
    render :layout => "kapa/layouts/document"
  end

  def index
    @filter = filter
    @forms = Kapa::Form.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
    @form_templates = Kapa::FormTemplate.all
  end

  def export
    @filter = filter
    send_data Kapa::Form.to_table(:as => :csv, :filter => @filter, :format => export_format),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "forms_#{Date.today}.csv"
  end

  def ensure_primary_dept_is_included
    if @form.depts.exclude?(@current_user.primary_dept)
      @form.depts = @form.depts + [@current_user.primary_dept]
      @form.save
    end
  end  

  private
  def form_param
    params.require(:form).permit(:form_template_id, :person_id, :attachable_id, :attachable_type, :lock, :note, :public, :dept, :depts => [])
  end

  def export_format
    {
      :document_id => [:document_id],
      :title => [:title],
      :id_number => [:person, :id_number],
      :last_name => [:person, :last_name],
      :first_name => [:person, :first_name],
      :cur_street => [:person, :cur_street],
      :cur_city => [:person, :cur_city],
      :cur_state => [:person, :cur_state],
      :cur_postal_code => [:person, :cur_postal_code],
      :cur_phone => [:person, :cur_phone],
      :email => [:person, :email],
      :email_alt => [:person, :email_alt],
      :updated => [:updated_at],
      :submitted => [:submitted_at],
      :lock =>[:lock]
    }
  end
end
