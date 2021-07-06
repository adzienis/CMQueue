class AddEnrollmentRefToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_reference :questions, :enrollment, null: false, foreign_key: true
  end
end