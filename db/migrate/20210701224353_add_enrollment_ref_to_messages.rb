class AddEnrollmentRefToMessages < ActiveRecord::Migration[6.1]
  def change
    add_reference :messages, :enrollment, null: false, foreign_key: true
  end
end
