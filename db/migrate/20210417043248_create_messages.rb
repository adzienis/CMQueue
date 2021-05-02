class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :question_state, foreign_key: true
      t.text :description, default: ''
      t.boolean :seen, default: false
      t.timestamps
    end
  end
end
