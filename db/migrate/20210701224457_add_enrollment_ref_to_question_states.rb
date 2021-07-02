class AddEnrollmentRefToQuestionStates < ActiveRecord::Migration[6.1]
  def change
    add_reference :question_states, :enrollment, null: false, foreign_key: true
  end
end
