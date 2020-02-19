module Kapa::FormsControllerBase
  extend ActiveSupport::Concern

  def show
    @form = Kapa::Form.find params[:id]
    @form_ext = @form.ext
    @form_template = @form.form_template
    @person = @form.person
    @person_ext = @person.ext
    @document_title = @form.title
    @document_id = @form.document_id
    @document_date = @form.date
    render :layout => "/kapa/layouts/document"
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

    # params.permit!.to_h.each_pair do |k, v|
    #   unless k =~ /(utf8)|(_method)|(authenticity_token)|(form)|(commit)|(controller)|(action)|(id)/
    #     @form.serialize(k.to_sym, v)
    #   end
    # end

    if @form.save
      flash[:success] = "Form was successfully updated."
    else
      flash[:danger] = error_message_for(@form)
    end
    redirect_to kapa_form_path(:id => @form)
  end

  def create
    @form = Kapa::Form.new(form_param)
    @form.dept = @current_user.primary_dept

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
  end

  def index
    @filter = filter
    @forms = Kapa::Form.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::Form.to_table(:as => :csv, :filter => @filter, :format => export_format),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "forms_#{Date.today}.csv"
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
