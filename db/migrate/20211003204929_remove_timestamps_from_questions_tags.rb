class RemoveTimestampsFromQuestionsTags < ActiveRecord::Migration[6.1]
  def change
    remove_column :questions_tags, :created_at, :string
    remove_column :questions_tags, :updated_at, :string
  end
end
