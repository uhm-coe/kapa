class Kapa::Admin::TermsController < Kapa::Admin::BaseController

  def index
    @filter = filter
    @per_page_selected = @filter.per_page || Rails.configuration.items_per_page
    @terms = Term.search(@filter).order("code").paginate(:page => params[:page], :per_page => @per_page_selected)
  end

  def show
    @term = Term.find params[:id]
  end

  def update
    @term = Term.find params[:id]
    @term.attributes = params[:term]

    if @term.save
      flash[:success] = "Term was successfully updated."
    else
      flash[:danger] = @term.errors.full_messages.join(", ")
    end
    redirect_to kapa_admin_term_path(:id => @term)
  end

  def new
    @term = Term.new
  end

  def create
    @term = Term.new
    @term.attributes = params[:term]

    unless @term.save
      flash[:danger] = @term.errors.full_messages.join(", ")
      redirect_to new_kapa_admin_term_path and return false
    end
    flash[:success] = "Term was successfully created."
    redirect_to kapa_admin_term_path(:id => @term)
  end

  def destroy
    @term = Term.find params[:id]

    unless @term.destroy
      flash[:danger] = error_message_for(@term)
      redirect_to kapa_admin_term_path(:id => @term) and return false
    end
    flash[:success] = "Term was successfully deleted."
    redirect_to kapa_admin_terms_path
  end

end
