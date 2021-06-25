class AddDiscardedAtToEnrollments < ActiveRecord::Migration[6.1]
  def change
    add_column :enrollments, :discarded_at, :datetime
    add_index :enrollments, :discarded_at
  end
end
