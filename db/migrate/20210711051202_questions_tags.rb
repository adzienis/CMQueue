class QuestionsTags < ActiveRecord::Migration[6.1]
  def change
    create_table :questions_tags do |t|
      t.belongs_to :question, foreign_key: true
      t.belongs_to :tag, foreign_key: true
      t.timestamps
    end
  end
end