module Kapa::ContactsControllerBase
  extend ActiveSupport::Concern

  def update
    @person = Kapa::Person.find(params[:id])
    @contact = @person.contact ||= @person.build_contact
    @contact.attributes=(contact_params)
    unless @contact.save
      flash[:danger] = error_message_for(@contact)
    end
    flash[:success] = "Contact record was successfully updated."
    redirect_to params[:return_path]
  end


  private
  def contact_params
    params.require(:contact).permit(:cur_phone, :mobile_phone, :email, :cur_street, :cur_city, :cur_state,
                                    :cur_postal_code, :per_street, :per_city, :per_state, :per_postal_code)
  end

end
