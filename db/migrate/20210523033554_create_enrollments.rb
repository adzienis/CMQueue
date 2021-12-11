# frozen_string_literal: true

class CreateEnrollments < ActiveRecord::Migration[6.1]
  def change
    create_table :enrollments do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :role, foreign_key: true
      # t.belongs_to :course
      t.string :semester
      t.index :semester
      t.timestamps
    end
  end
end
