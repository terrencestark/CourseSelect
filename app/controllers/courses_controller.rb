class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update]
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end
  
  def open
    @course = Course.find_by_id(params[:id])
    @course.isopen = true
    @course.save
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end
  def close
    @course = Course.find_by_id(params[:id])
    @course.isopen = false
    @course.save
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  #-------------------------for students----------------------

  def list
    # mao changed #2 for searching  
    @course=Course.where(isopen: true)
    @courses_number = -1 # used for search result
    unless params[:query].blank?
      @course=Course.where(isopen: true).where( 'name  LIKE :search OR course_code LIKE :search OR course_type LIKE :search OR teaching_type LIKE :search OR exam_type LIKE :search', search:"%#{params[:query]}%")
      @courses_number=@course.length
    end
    @course=@course-current_user.courses
    # mao changed #2 for searching  
    # ts add
    @course.each do |course0|
      course0_week = get_week_bool_matrix(course0.course_week)
      course0_time = get_time_bool_matrix(course0.course_time)
      current_user.courses.each do |course1|
        course1_week = get_week_bool_matrix(course1.course_week)
        if if_has_same_week(course0_week,course1_week)==true
          course1_time = get_time_bool_matrix(course1.course_time)
          if if_has_same_time(course0_time,course1_time)==true
            course0.conflict=true
            course0.conflict_course=course1.name
            course0.save
            break
          else
            course0.conflict=false
            course0.conflict_course=""
            course0.save
          end
        end
      end
    end
  end    # mao added 1 "end" to make 5 "end"s here totally
    


  def select
    @course=Course.find_by_id(params[:id])
    current_user.courses<<@course
    @course.student_num +=1
    @course.save
    flash={:suceess => "成功选择课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    @course.student_num -=1
    @course.save
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def show_courses_table
    @ts_courses = current_user.courses
    @course_matrix = nil
    current_user.courses.each do |course|
      # c.course_time c.name
      # hash_1 {course_name: "math", course_time: "周四(7-8)"}
      tem_hash = {course_name: course.name, course_time: course.course_time}
      @course_matrix = merge_course_to_hash_matrix(@course_matrix, tem_hash)
    end
  end

  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end
  
end
