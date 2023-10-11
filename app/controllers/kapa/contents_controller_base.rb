module Kapa::ContentsControllerBase
  extend ActiveSupport::Concern

  def show
    @content = Kapa::Content.find params[:id]
    @content_ext = @content.ext
    @content_pages = Kapa::Content.select("distinct page").where("length(page) > 0").order('1').collect { |p| p.page }
  end

  def new
    @filter = filter
    @content = Kapa::Content.new
    @content.page = @filter.content_page
    @content_pages = Kapa::Content.select("distinct page").where("length(page) > 0").order('1').collect { |p| p.page }
  end

  def update
    @content = Kapa::Content.find params[:id]
    @content.attributes= content_params
    @content.update_serialized_attributes!(:_ext, params[:content_ext]) if params[:content_ext].present?

    if @content.save
      flash[:notice] = "Content was successfully updated."
    else
      flash[:alert] = error_message_for(@content)
    end
    redirect_to kapa_content_path(:id => @content)
  end

  def create
    @content = Kapa::Content.new
    @content.attributes= content_params

    unless @content.save
      flash[:alert] = error_message_for(@content)
      redirect_to new_kapa_content_path and return false
    end
    flash[:notice] = 'Content was successfully created.'
    redirect_to kapa_content_path(:id => @content, :anchor => params[:anchor])
  end

  def index
    @filter = filter
    @modal = true if @filter.page.blank?
    @contents = Kapa::Content.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end


  def export
    @filter = filter
    send_data Kapa::Content.to_table(:as => :csv, :filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "Contents_#{DateTime.now}.csv"
  end

  private
  def content_params
    params.require(:content).permit(:page, :region, :html)
  end
end
