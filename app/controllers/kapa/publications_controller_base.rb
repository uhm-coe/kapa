module Kapa::PublicationsControllerBase
  extend ActiveSupport::Concern

  def index
    @filter = filter
    @publications = Kapa::Publication.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def show
  end

  def new
  end

  def create
  end

  def update
  end

  def destroy
  end

  def export
  end
end
