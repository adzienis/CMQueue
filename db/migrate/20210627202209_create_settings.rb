class CreateSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :settings do |t|
      t.references :resource, polymorphic: true
      #t.references :metadata
      #t.string :key, null: false
      #t.string :value, null: false
      #t.text :description, null: false
      #t.text :label, null: false
      #t.integer :setting_type, default: 0, null: false
      t.json :value
      t.timestamps
    end

  end
end
