module Kapa::ContactsControllerBase
  extend ActiveSupport::Concern

  def update
    @person = Kapa::Person.find(params[:id])
    @contact = @person.contact ||= @person.build_contact
    @contact.entity_type = "Person"
    @contact.attributes=(params[:contact])
    unless @contact.save
      flash[:danger] = error_message_for(@contact)
    end
    flash[:success] = "Contact record was successfully updated."
    # params[:return_uri][:anchor] = params[:anchor]
    # TODO: Fix redirect_to path
    redirect_to params[:return_uri]
  end

end
