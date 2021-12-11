class ConvertTimestampToTimestamptz < ActiveRecord::Migration[6.1]
  def change
    change_column :question_states, :created_at, :timestamptz
    change_column :question_states, :updated_at, :timestamptz
    change_column :question_states, :acknowledged_at, :timestamptz

    change_column :analytics_dashboards, :created_at, :timestamptz
    change_column :analytics_dashboards, :updated_at, :timestamptz

    change_column :announcements, :created_at, :timestamptz
    change_column :announcements, :updated_at, :timestamptz

    change_column :certificates, :created_at, :timestamptz
    change_column :certificates, :updated_at, :timestamptz

    change_column :courses, :created_at, :timestamptz
    change_column :courses, :updated_at, :timestamptz

    change_column :enrollments, :created_at, :timestamptz
    change_column :enrollments, :updated_at, :timestamptz

    change_column :group_members, :created_at, :timestamptz
    change_column :group_members, :updated_at, :timestamptz

    change_column :notifications, :created_at, :timestamptz
    change_column :notifications, :updated_at, :timestamptz

    change_column :oauth_applications, :created_at, :timestamptz
    change_column :oauth_applications, :updated_at, :timestamptz

    change_column :question_queues, :created_at, :timestamptz
    change_column :question_queues, :updated_at, :timestamptz

    change_column :question_states, :created_at, :timestamptz
    change_column :question_states, :updated_at, :timestamptz

    change_column :questions, :created_at, :timestamptz
    change_column :questions, :updated_at, :timestamptz

    change_column :roles, :created_at, :timestamptz
    change_column :roles, :updated_at, :timestamptz

    change_column :settings, :created_at, :timestamptz
    change_column :settings, :updated_at, :timestamptz

    change_column :tag_groups, :created_at, :timestamptz
    change_column :tag_groups, :updated_at, :timestamptz

    change_column :tags, :created_at, :timestamptz
    change_column :tags, :updated_at, :timestamptz

    change_column :users, :created_at, :timestamptz
    change_column :users, :updated_at, :timestamptz
  end
end
