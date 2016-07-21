module Kapa::ProgramOffersControllerBase
  extend ActiveSupport::Concern

  def update
    @program_offer = Kapa::ProgramOffer.find params[:id]
    @program_offer.attributes = program_offer_params

    if @program_offer.save
      flash[:success] = "Offering record was successfully updated."
    else
      flash[:danger] = @program_offer.errors.full_messages.join(", ")
    end
    redirect_to kapa_program_path(:id => @program_offer.program, :anchor => params[:anchor], :offer_panel => params[:offer_panel])
  end

  def create
    @program = Kapa::Program.find(params[:id])
    @program_offer = @program.program_offers.build
    @program_offer.attributes = program_offer_params

    if @program_offer.save
      flash[:success] = "Offering record was successfully created."
    else
      flash[:danger] = @program_offer.errors.full_messages.join(", ")
    end
    redirect_to kapa_program_path(:id => @program, :anchor => params[:anchor], :offer_panel => @program_offer.id)
  end

  def destroy
    @program_offer = Kapa::ProgramOffer.find params[:id]

    if @program_offer.destroy
      flash[:success] = "Program offer was successfully deleted."
    else
      flash[:danger] = error_message_for(@program_offer)
    end
    redirect_to kapa_program_path(:id => @program_offer.program, :anchor => params[:anchor])
  end

  def program_offer_params
    params.require(:program_offer).permit(:description, :distribution, :start_term_id, :end_term_id, :available_major=>[])
  end
end
