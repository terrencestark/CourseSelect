class AddConflictAttribute < ActiveRecord::Migration
  def change
    add_column :courses, :conflict, :boolean,default: false
  end
end
