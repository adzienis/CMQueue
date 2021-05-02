class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.belongs_to :course, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.timestamps
      t.text :title
      t.text :tried
      t.text :description
      t.text :notes
      t.text :location
    end
  end
end