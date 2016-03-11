module Kapa::PersonReferencesControllerBase
  extend ActiveSupport::Concern

  def show
    @person_reference = Kapa::PersonReference.find(params[:id])
    @referenceable = @person_reference.referenceable
    @person = @referenceable.person
  end

  def new
  end

  def create
    @person_reference = Kapa::PersonReference.new(person_reference_params)
    @referenceable = Kapa::Case.find(params[:referenceable_id])
    @referenceable.person_references << @person_reference

    unless @person_reference.save
      flash[:danger] = error_message_for(@person_reference)
      redirect_to kapa_case_path(:id => @referenceable) and return false
    end

    flash[:success] = "Person was successfully created."
    redirect_to kapa_case_path(:id => @referenceable, :anchor => "involved_person")
  end

  def update
    @person_reference = Kapa::PersonReference.find(params[:id])
    @referenceable = @person_reference.referenceable_id
    @person_reference.attributes = person_reference_params

    unless @person_reference.save
      flash[:danger] = @person_reference.errors.full_messages.join(", ")
      redirect_to kapa_referenceable_path(:id => @referenceable) and return false
    end

    flash[:success] = "Person was successfully updated."
    redirect_to kapa_referenceable_path(:id => @referenceable, :anchor => "involved_person")
  end

  def destroy
    @person_reference = Kapa::PersonReference.find(params[:id])
    @referenceable = @person_reference.referenceable
    unless @person_reference.destroy
      flash[:danger] = error_message_for(@person_reference)
      redirect_to kapa_referenceable_path(:id => @referenceable) and return false
    end
    flash[:success] = "Person was successfully deleted."
    redirect_to kapa_referenceable_path(:id => @referenceable, :anchor => "involved_person")
  end

  def export
  end

  private
  def person_reference_params
    params.require(:person_reference).permit(:referenceable_id, :type, :person_id, :sequence, :yml, :xml)
  end

  # Only select and assign fields relevant to person_reference type. Unassigned fields will be nil.
  #def person_reference_params_subset(params)
  #  referenceable params[:person_reference][:type]
  #    when "internal"
  #      person_reference_params.slice("type", "person_id")
  #    when "external"
  #      person_reference_params.slice("type", "last_name", "first_name", "middle_initial")
  #  end
  #end
end
