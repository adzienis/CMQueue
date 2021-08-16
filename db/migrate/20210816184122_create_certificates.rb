class CreateCertificates < ActiveRecord::Migration[6.1]
  def change
    create_table :certificates do |t|
      t.references :course, null: false, foreign_key: true
      t.binary :data

      t.timestamps
    end
  end
end
