class AddLastVisitedAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_active_at, :datetime, default: nil
    add_column :users, :last_pinged_at, :datetime, default: nil
  end
end
