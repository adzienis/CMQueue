class CreateGroupMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :group_members do |t|
      t.integer :individual_id
      t.string :individual_type

      t.integer :group_id
      t.string :group_type

      t.timestamps
    end
  end
end
