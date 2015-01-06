class Admin::ProgramOffersController < ApplicationController

  def update
    @program_offer = ProgramOffer.find params[:id]
    @program_offer.attributes = params[:program_offer]

    if @program_offer.save
      flash[:success] = "Offering record was successfully updated."
    else
      flash[:danger] = @program_offer.errors.full_messages.join(", ")
    end
    redirect_to admin_program_path(:id => @program_offer.program_id)
  end

  def create
    @program = Program.find(params[:id])
    @program_offer = @program.program_offers.build
    @program_offer.attributes = params[:program_offer]

    if @program_offer.save
      flash[:success] = "Offering record was successfully created."
    else
      flash[:danger] = @program_offer.errors.full_messages.join(", ")
    end
    redirect_to admin_program_path(:id => @program)
  end

end
