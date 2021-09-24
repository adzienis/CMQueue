class CreateTagGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :tag_groups do |t|
      t.references :course, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, default: ""
      t.jsonb :validations

      t.timestamps
    end
  end
end
