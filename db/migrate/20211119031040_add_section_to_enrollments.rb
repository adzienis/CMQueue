class AddSectionToEnrollments < ActiveRecord::Migration[6.1]
  def change
    add_column :enrollments, :section, :string
  end
end
