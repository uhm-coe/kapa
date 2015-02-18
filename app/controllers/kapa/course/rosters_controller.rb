class Kapa::Course::RostersController < Kapa::Course::BaseController

  def show
#    session[:filter_course][:assessment_rubric_id] = nil if request.get? and params[:format] != "file"
    @filter = filter((request.get? and params[:format] != "file") ? {:assessment_rubric_id => nil} : {})
    @course = Course.find(params[:id])
    @assessment_rubrics = @course.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    refresh_table

    respond_to do |format|
      format.html
      format.file {
        csv_string = CSV.generate do |csv|
          title = [@course.name, @course.term_desc, @course.instructor, @assessment_rubric.title]
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
          :filename     => "#{@course.name}_#{@course.term_desc}.csv"
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
    @course = Course.find(params[:id])
    @assessment_rubric = AssessmentRubric.find(@filter.assessment_rubric_id)
    refresh_table
    render :partial => "/kapa/course/table", :layout => false
  end

  def index
    @filter = filter
    @courses = Course.search(@filter).order("subject, number, section").paginate(:page => params[:page])
  end

  def export
    @filter = filter
    logger.debug "----filter: #{@filter.inspect}"
    send_data Course.to_csv(@filter),
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "courses_#{Term.find(@filter.term_id).description if @filter.term_id}.csv"
  end

  private
  def refresh_table
    @course_registrations = @course.course_registrations
    @table = @course.table_for(@assessment_rubric)
    session[:score] = @table
    session[:filter_course][:assessment_rubric_id] = @assessment_rubric.id
  end

end
