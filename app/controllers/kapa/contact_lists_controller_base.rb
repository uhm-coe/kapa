module Kapa::ContactListsControllerBase
  extend ActiveSupport::Concern

  def show
    @contact_list = Kapa::ContactList.find(params[:id])
    @contact_list_ext = @contact_list.ext
  end

  def update
    @contact_list = Kapa::ContactList.find(params[:id])
    @contact_list.attributes = contact_list_params
    @contact_list.update_serialized_attributes!(:_ext, params[:contact_list_ext]) if params[:contact_list_ext].present?

    if @contact_list.save
      flash[:success] = "Contact list was successfully updated."
    else
      flash[:danger] = error_message_for(@contact_list)
    end
    redirect_to kapa_contact_list_path(:id => @contact_list)
  end

  def create
    @contact_list = Kapa::ContactList.new(contact_list_params)
    @contact_list.dept = [@current_user.primary_dept]

    unless @contact_list.save
      flash[:danger] = error_message_for(@contact_list)
      redirect_to(kapa_error_path) and return false
    end

    flash[:success] = "Contact list was successfully created."
    redirect_to kapa_contact_list_path(:id => @contact_list)
  end

  def destroy
    @contact_list = Kapa::ContactList.find params[:id]
    unless @contact_list.destroy
      flash[:danger] = error_message_for(@contact_list)
      redirect_to kapa_contact_list_path(:id => @contact_list) and return false
    end
    flash[:success] = "Contact list was successfully deleted."
    redirect_to kapa_contact_lists_path
  end

  def index
    @filter = filter
    @contact_lists = Kapa::ContactList.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::ContactList.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "contact_lists_#{filter.type}.csv"
  end

  private
  def contact_list_params
    params.require(:contact_list).permit(:name, :description, :note, :contact_list_member_ids => [])
  end
end
