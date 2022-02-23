class CreateQueueStatusLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :queue_status_logs do |t|
      t.references :course, null: false, foreign_key: true
      t.boolean :new_status
      t.integer :number_students
      t.text :notes

      t.timestamps
    end
  end
end
