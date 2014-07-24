class Admin::ProgramOffersController < ApplicationController

  def update
    @program_offer = ProgramOffer.find params[:id]
    @program_offer.attributes = params[:program_offer]

    unless @program_offer.save
      flash.now[:notice1] = @program_offer.errors.full_messages.join(", ")
      render_notice and return false
    end
    flash[:notice1] = "Offering record was successfully updated."
    render_notice
  end

  def create
    @program = Program.find(params[:id])
    @program_offer = @program.program_offers.build
    @program_offer.attributes = params[:program_offer]

    unless @program_offer.save
      flash.now[:notice1] = @program_offer.errors.full_messages.join(", ")
      render_notice and return false
    end
    flash[:notice1] = "Offering record was successfully created."
    redirect_to admin_program_path(:action => :show, :id => @program, :focus => params[:focus])
    end

end
