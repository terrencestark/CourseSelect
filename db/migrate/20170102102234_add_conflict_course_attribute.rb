class AddConflictCourseAttribute < ActiveRecord::Migration
  def change
    add_column :courses, :conflict_course, :string,default: ""
  end
end
