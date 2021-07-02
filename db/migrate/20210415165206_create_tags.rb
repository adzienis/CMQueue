# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.belongs_to :course, foreign_key: true
      t.timestamps
      t.boolean :archived, default: true
      t.text :name, default: ''
      t.text :description, default: ''
    end
  end
end
