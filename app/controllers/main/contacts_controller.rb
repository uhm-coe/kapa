class Main::ContactsController < ApplicationController

  def update
    @person = Person.find(params[:id])
    @contact = @person.contact ||= @person.build_contact
    @contact.entity_type = "Person"
    @contact.attributes=(params[:contact])
    unless @contact.save
      flash[:notice1] = error_message_for(@contact)
    end
    flash[:notice1] = "Contact record was successfully updated."
#    params[:return_uri][:focus] = params[:focus]
#    redirect_to params[:return_uri]
    render_notice
  end

end
