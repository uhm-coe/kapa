module Kapa::TextsControllerBase
  extend ActiveSupport::Concern

  def show
    @text = Kapa::Text.find(params[:id])
    @text_ext = @text.ext
    @person = @text.person
    @person_ext = @person.ext if @person
    @title = @text.title
    render :layout => "kapa/layouts/document"
  end

  def update
    @text = Kapa::Text.find(params[:id])
    @person = @text.person
    @text.attributes = text_param
    @text.update_serialized_attributes!(:_ext, params[:text_ext]) if params[:text_ext].present?

    if @text.save
      flash[:success] = "Document was successfully updated."
    else
      flash[:danger] = error_message_for(@text)
    end
    redirect_to kapa_text_path(:id => @text)
  end

  def create
    @text = Kapa::Text.new(text_param)
    @text.dept = [@current_user.primary_dept]

    unless @text.save
      flash[:danger] = error_message_for(@text)
      redirect_to(kapa_error_path) and return false
    end

    flash[:success] = "Document was successfully created."
    redirect_to params[:return_path]
  end

  def destroy
    @text = Kapa::Text.find params[:id]
    unless @text.destroy
      flash[:danger] = error_message_for(@text)
      redirect_to kapa_text_path(:id => @text) and return false
    end
    flash[:success] = "Document was successfully deleted."
    render(:text => "<script>window.onunload = window.opener.location.reload(); close();</script>")
  end

  def index
    @filter = filter
    @texts = Kapa::Text.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::Text.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "texts_#{filter.type}.csv"
  end

  private
  def text_param
    params.require(:text).permit(:person_id, :attachable_id, :attachable_type, :text_template_id, :title, :body, :status, :lock, :note)
  end
end
