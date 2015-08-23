module Kapa::TermsControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @terms = Kapa::Term.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def show
    @term = Kapa::Term.find params[:id]
  end

  def update
    @term = Kapa::Term.find params[:id]
    @term.attributes = term_params

    if @term.save
      flash[:success] = "Term was successfully updated."
    else
      flash[:danger] = @term.errors.full_messages.join(", ")
    end
    redirect_to kapa_term_path(:id => @term)
  end

  def new
    @term = Kapa::Term.new
  end

  def create
    @term = Kapa::Term.new
    @term.attributes = term_params

    unless @term.save
      flash[:danger] = @term.errors.full_messages.join(", ")
      redirect_to new_kapa_term_path and return false
    end
    flash[:success] = "Term was successfully created."
    redirect_to kapa_term_path(:id => @term)
  end

  def destroy
    @term = Kapa::Term.find params[:id]

    unless @term.destroy
      flash[:danger] = error_message_for(@term)
      redirect_to kapa_term_path(:id => @term) and return false
    end
    flash[:success] = "Term was successfully deleted."
    redirect_to kapa_terms_path
  end

  def term_params
    params.require(:term).permit(:code, :description, :description_short, :start_date, :end_date, :dept, :sequence,
                                 :academic_year, :calendar_year, :fiscal_year, :regular_term, :active)
  end
end
