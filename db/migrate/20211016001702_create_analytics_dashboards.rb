class CreateAnalyticsDashboards < ActiveRecord::Migration[6.1]
  def change
    create_table :analytics_dashboards do |t|
      t.jsonb :data
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
