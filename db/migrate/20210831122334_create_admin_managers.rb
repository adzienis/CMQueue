class CreateAdminManagers < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_managers do |t|

      t.timestamps
    end
  end
end
