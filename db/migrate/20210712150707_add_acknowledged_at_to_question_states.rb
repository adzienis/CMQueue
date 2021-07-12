class AddAcknowledgedAtToQuestionStates < ActiveRecord::Migration[6.1]
  def change
    add_column :question_states, :acknowledged_at, :datetime
  end
end
