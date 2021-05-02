class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.text :given_name
      t.text :family_name
      t.text :email
      t.timestamps
      t.belongs_to :question_state
    end
  end
end
