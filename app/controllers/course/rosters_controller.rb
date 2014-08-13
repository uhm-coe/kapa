class Course::RostersController < Course::BaseController

  def show
#    session[:filter_course][:assessment_rubric_id] = nil if request.get? and params[:format] != "file"
    @filter = filter((request.get? and params[:format] != "file") ? {:assessment_rubric_id => nil} : {})
    @assessment_course = AssessmentCourse.find(params[:id])
    @assessment_rubrics = @assessment_course.assessment_rubrics
    @assessment_rubric = @filter.assessment_rubric_id ? AssessmentRubric.find(@filter.assessment_rubric_id) : @assessment_rubrics.first
    refresh_table
    
    respond_to do |format|
      format.html
      format.file {
        csv_string = CSV.generate do |csv|
          title = [@assessment_course.name, @assessment_course.academic_period_desc, @assessment_course.instructor, @assessment_rubric.title]
          csv << title
          header_row = [:id_number, :last_name, :first_name]
          @assessment_rubric.assessment_criterions.each {|c| header_row.push("#{c.criterion}:#{c.criterion_desc}")}
          csv << header_row

          @assessment_course_registrations.each do |r|
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
          :filename     => "#{@assessment_course.name}_#{@assessment_course.academic_period_desc}.csv"
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
 #       score = AssessmentScore.find(:first, :conditions => "assessment_scorable_type = 'AssessmentCourseRegistration' and assessment_scorable_id = #{registration_id} and assessment_criterion_id = #{criterion_id}")
 #       score = AssessmentScore.new(:assessment_course_registration_id => registration_id, :assessment_criterion_id => criterion_id) if score.nil?
        score = AssessmentScore.find_or_initialize_by_assessment_scorable_type_and_assessment_scorable_id_and_assessment_criterion_id('AssessmentCourseRegistration', registration_id, criterion_id)
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
    @assessment_course = AssessmentCourse.find(params[:id])
    @assessment_rubric = AssessmentRubric.find(@filter.assessment_rubric_id)
    refresh_table
    render :partial => "/course/table", :layout => false
  end

  def index
    @filter = course_filter
    @assessment_courses = AssessmentCourse.paginate(:page => params[:page], :per_page => 20, :include => [[:assessment_course_registrations => :assessment_scores]], :conditions => @filter.conditions, :order => "subject, number, section")
  end

  def export
    @filter = course_filter
    sql =  "SELECT
              assessment_courses.*,
              assessment_score_results.*,
              (select count(*) from assessment_course_registrations where status like 'R%' and assessment_course_id = assessment_courses.id) as registered
              FROM
              assessment_courses
              LEFT OUTER JOIN (
                SELECT
                assessment_course_registrations.assessment_course_id,
                assessment_rubrics.title as assessment,
                assessment_criterions.criterion,
                assessment_criterions.criterion_desc,
                sum(if(assessment_scores.rating = '2', 1, 0)) as target,
                sum(if(assessment_scores.rating = '1', 1, 0)) as acceptable,
                sum(if(assessment_scores.rating = '0', 1, 0)) as unacceptable,
                sum(if(assessment_scores.rating = 'N', 1, 0)) as na
                FROM assessment_scores
                INNER JOIN assessment_course_registrations on assessment_scores.assessment_scorable_type = 'AssessmentCourseRegistration' and assessment_scores.assessment_scorable_id = assessment_course_registrations.id
                INNER JOIN assessment_criterions on assessment_scores.assessment_criterion_id = assessment_criterions.id
                INNER JOIN assessment_rubrics on assessment_criterions.assessment_rubric_id = assessment_rubrics.id
                WHERE 1=1
                and assessment_course_registrations.status like 'R%'
                and assessment_scores.rating not in ('')
                GROUP BY
                assessment_course_registrations.assessment_course_id,
                assessment_rubrics.title,
                assessment_criterions.criterion,
                assessment_criterions.criterion_desc
              ) as assessment_score_results
              ON assessment_courses.id = assessment_score_results.assessment_course_id
            WHERE ?
            ORDER BY academic_period, subject, number, section, crn"
    assessment_courses = AssessmentCourse.find_by_sql(@filter.query(sql))
    csv_string = CSV.generate do |csv|
      csv << [:academic_period,
              :academic_period_desc,
              :subject,
              :number,
              :section,
              :crn,
              :title,
              :instructor,
              :assessment,
              :criterion,
              :criterion_desc,
              :target,
              :acceptable,
              :unacceptable,
              :na,
              :registered]
      assessment_courses.each do |c|
        csv << [c.academic_period,
                c.academic_period_desc,
                c.subject,
                c.number,
                c.section,
                c.crn,
                c.title,
                c.instructor,
                c.assessment,
                c.criterion,
                c.criterion_desc,
                c.target,
                c.acceptable,
                c.unacceptable,
                c.na,
                c.registered]
      end

    end
    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "assessment_courses_#{ApplicationProperty.lookup_description("academic_period", @filter.academic_period)}.csv"
  end
  
  private
  def refresh_table
    @assessment_course_registrations = @assessment_course.assessment_course_registrations
    @table = @assessment_course.table_for(@assessment_rubric)
    session[:score] = @table
    session[:filter_course][:assessment_rubric_id] = @assessment_rubric.id
  end
  
  def course_filter
    f = filter
    f.append_condition "assessment_courses.status = 'A'"
    f.append_condition "assessment_courses.academic_period = ?", :academic_period
    f.append_condition "assessment_courses.subject = ?", :subject
    f.append_condition "concat(assessment_courses.subject, assessment_courses.number, '-', assessment_courses.section) like ?", :course_name, :like => true
    if @current_user.access_scope >= 3
      # do nothing
    elsif @current_user.access_scope == 2
      f.append_property_condition "concat(assessment_courses.subject, assessment_courses.number) in (?)", :assessment_course, :depts => @current_user.depts unless @current_user.manage? :course
    elsif @current_user.access_scope == 1
      # not implemented yet
    else
      f.append_condition "1=2"
    end

    return f
  end  
end
