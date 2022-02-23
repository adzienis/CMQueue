class CreateUserQueueStatusLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :user_queue_status_logs do |t|
      t.references :queue_status_log, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
