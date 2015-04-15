module Kapa::Main::Concerns::ContactsController
  extend ActiveSupport::Concern

  def update
    @person = Person.find(params[:id])
    @contact = @person.contact ||= @person.build_contact
    @contact.entity_type = "Person"
    @contact.attributes=(params[:contact])
    unless @contact.save
      flash[:danger] = error_message_for(@contact)
    end
    flash[:success] = "Contact record was successfully updated."
    # params[:return_uri][:focus] = params[:focus]
    # TODO: Fix redirect_to path
    redirect_to params[:return_uri]
  end

end
