class AddArchivedAtToEnrollments < ActiveRecord::Migration[6.1]
  def change
    add_column :enrollments, :archived_at, :datetime, default: nil
  end
end
