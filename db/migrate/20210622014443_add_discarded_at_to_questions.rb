class AddDiscardedAtToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :questions, :discarded_at, :datetime
    add_index :questions, :discarded_at
  end
end
