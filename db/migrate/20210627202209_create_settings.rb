class CreateSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :settings do |t|
      t.references :resource, polymorphic: true
      t.string :key, null: false
      t.string :value, null: false
      t.integer :setting_type, default: 0, null: false
      t.timestamps
    end

  end
end
