class CreateCoursesUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :courses_users do |t|
      t.belongs_to :course
      t.belongs_to :user
      t.timestamps
    end
  end
end
