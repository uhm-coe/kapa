module Kapa::Course::OffersControllerBase
  extend ActiveSupport::Concern

  def show
#    session[:filter_course][:assessment_rubric_id] = nil if request.get? and params[:format] != "file"
    @filter = filter((request.get? and params[:format] != "file") ? {:assessment_rubric_id => nil} : {})
    @course_offer = Kapa::CourseOffer.find(params[:id])
    @assessment_rubrics = @course_offer.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? Kapa::AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    @course_registrations = @course_offer.course_registrations
    @table = Kapa::AssessmentScore.scores(@course_registrations, @assessment_rubric)
#    session[:score] = @table

    respond_to do |format|
      format.html
      format.file {
        csv_string = CSV.generate do |csv|
          title = [@course_offer.name, @course_offer.term_desc, @course_offer.instructor, @assessment_rubric.title]
          csv << title
          header_row = [:id_number, :last_name, :first_name]
          @assessment_rubric.assessment_criterions.each { |c| header_row.push("#{c.criterion}:#{c.criterion_desc}") }
          csv << header_row

          @course_registrations.each do |r|
            row = [r.rsend(:person, :id_number),
                   r.rsend(:person, :last_name),
                   r.rsend(:person, :first_name)]
            @assessment_rubric.assessment_criterions.each { |c| row.push(@table["#{r.id}_#{c.id}"]) }
            csv << row
          end
        end

        send_data csv_string,
                  :type => "application/csv",
                  :disposition => "inline",
                  :filename => "#{@course_offer.name}_#{@course_offer.term_desc}.csv"
      }
    end
  end

  def update
    @filter = filter
    if params[:assessment_scores]
      ActiveRecord::Base.transaction do
        begin
#          params[:assessment_scores].each_pair do |k, v|
            #Skip update if score is the same as previous one
            if session[:score][k] != v
              scorable_id = k.split("_").first
              criterion_id = k.split("_").last
              score = Kapa::AssessmentScore.find_or_initialize_by(:assessment_scorable_type => "Kapa::CourseRegistration", :assessment_scorable_id => scorable_id, :assessment_criterion_id => criterion_id)
              score.rating = v
              score.rated_by = @current_user.uid
              score.save!
            end
#          end
        rescue ActiveRecord::StatementInvalid
          flash[:danger] = "There was an error updating scores. Please try again."
          redirect_to kapa_course_offer_path(:id => params[:id], :assessment_rubric_id => @filter.assessment_rubric_id) and return false
        end
      end
    end
    redirect_to  kapa_course_offer_path(:id => params[:id], :assessment_rubric_id => @filter.assessment_rubric_id)
  end

  def index
    @filter = filter
    @course_offers = Kapa::CourseOffer.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{@filter.inspect}"
    send_data Kapa::CourseOffer.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "courses_#{Kapa::Term.find(@filter.term_id).description if @filter.term_id.present?}.csv"
  end
end
