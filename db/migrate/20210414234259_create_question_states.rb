# frozen_string_literal: true

class CreateQuestionStates < ActiveRecord::Migration[6.1]
  def change
    create_table :question_states do |t|
      t.belongs_to :question, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.timestamps
      t.integer :state, null: false
    end
  end
end
