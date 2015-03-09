class Kapa::Course::OffersController < Kapa::Course::BaseController

  def show
#    session[:filter_course][:assessment_rubric_id] = nil if request.get? and params[:format] != "file"
    @filter = filter((request.get? and params[:format] != "file") ? {:assessment_rubric_id => nil} : {})
    @course_offer = CourseOffer.find(params[:id])
    @assessment_rubrics = @course_offer.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    refresh_table

    respond_to do |format|
      format.html
      format.file {
        csv_string = CSV.generate do |csv|
          title = [@course_offer.name, @course_offer.term_desc, @course_offer.instructor, @assessment_rubric.title]
          csv << title
          header_row = [:id_number, :last_name, :first_name]
          @assessment_rubric.assessment_criterions.each {|c| header_row.push("#{c.criterion}:#{c.criterion_desc}")}
          csv << header_row

          @course_registrations.each do |r|
            row =  [rsend(r.person, :id_number),
                    rsend(r.person, :last_name),
                    rsend(r.person, :first_name)]
            @assessment_rubric.assessment_criterions.each {|c| row.push(@table["#{r.id}_#{c.id}"]) }
            csv << row
          end
        end

        send_data csv_string,
          :type         => "application/csv",
          :disposition  => "inline",
          :filename     => "#{@course_offer.name}_#{@course_offer.term_desc}.csv"
      }
    end
  end

  def update
    #      logger.debug "-------update called-----"
    #      logger.debug "session=#{session[:score].inspect}"
    #      logger.debug " params=#{params[:score].inspect}"

    params[:score].each_pair do |k, v|
      if session[:score][k] != v
        registration_id = k.split("_").first
        criterion_id = k.split("_").last
 #       score = AssessmentScore.find(:first, :conditions => "assessment_scorable_type = 'CourseRegistration' and assessment_scorable_id = #{registration_id} and assessment_criterion_id = #{criterion_id}")
 #       score = AssessmentScore.new(:course_registration_id => registration_id, :assessment_criterion_id => criterion_id) if score.nil?
        score = AssessmentScore.find_or_initialize_by_assessment_scorable_type_and_assessment_scorable_id_and_assessment_criterion_id('CourseRegistration', registration_id, criterion_id)
        logger.debug "--score: #{score.inspect}"
        score.rating = v
        score.rated_by = @current_user.uid
        unless score.save
          flash[:save_notice] = "There was an error! Please try again."
          render :partial => "save", :layout => false
          return false
        end
      end
    end
    session[:score] = params[:score]
#    flash[:save_notice] = "Last saved on #{DateTime.now.strftime("%H:%M:%S")}"
    @filter = filter
    @course_offer = CourseOffer.find(params[:id])
    @assessment_rubric = AssessmentRubric.find(@filter.assessment_rubric_id)
    refresh_table
    render :partial => "/kapa/course/table", :layout => false
  end

  def index
    @filter = filter
    @course_offers = CourseOffer.search(@filter).order("subject, number, section").paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{@filter.inspect}"
    send_data CourseOffer.to_csv(@filter),
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "courses_#{Term.find(@filter.term_id).description if @filter.term_id.present?}.csv"
  end

  private
  def refresh_table
    @course_registrations = @course_offer.course_registrations
    @table = @course_offer.table_for(@assessment_rubric)
    session[:score] = @table
    session[:filter_course][:assessment_rubric_id] = @assessment_rubric.id
  end

end
