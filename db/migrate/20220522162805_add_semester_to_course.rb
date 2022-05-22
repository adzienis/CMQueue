class AddSemesterToCourse < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :semester, :string, null: true
  end
end
