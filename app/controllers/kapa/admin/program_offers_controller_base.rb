module Kapa::Admin::ProgramOffersControllerBase
  extend ActiveSupport::Concern

  def update
    @program_offer = Kapa::ProgramOffer.find params[:id]
    @program_offer.attributes = params[:program_offer]

    if @program_offer.save
      flash[:success] = "Offering record was successfully updated."
    else
      flash[:danger] = @program_offer.errors.full_messages.join(", ")
    end
    redirect_to kapa_admin_program_path(:id => @program_offer.program_id, :focus => params[:focus], :offer_panel => params[:offer_panel])
  end

  def create
    @program = Kapa::Program.find(params[:id])
    @program_offer = @program.program_offers.build
    @program_offer.attributes = params[:program_offer]

    if @program_offer.save
      flash[:success] = "Offering record was successfully created."
    else
      flash[:danger] = @program_offer.errors.full_messages.join(", ")
    end
    redirect_to kapa_admin_program_path(:id => @program, :focus => params[:focus], :offer_panel => @program_offer.id)
  end

  def destroy
    @program_offer = Kapa::ProgramOffer.find params[:id]

    if @program_offer.destroy
      flash[:success] = "Program offer was successfully deleted."
    else
      flash[:danger] = error_message_for(@program_offer)
    end
    redirect_to kapa_admin_program_path(:id => @program_offer.program_id, :focus => params[:focus])
  end
end
