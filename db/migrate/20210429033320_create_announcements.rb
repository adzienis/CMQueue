# frozen_string_literal: true

class CreateAnnouncements < ActiveRecord::Migration[6.1]
  def change
    create_table :announcements do |t|
      t.string :title, default: ""
      t.text :description, default: ""
      t.boolean :visible, default: true
      t.timestamps
    end
  end
end
