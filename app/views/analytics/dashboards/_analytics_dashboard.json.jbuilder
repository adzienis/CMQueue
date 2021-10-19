json.extract! analytics_dashboard, :id, :url, :title, :course_id, :created_at, :updated_at
json.url analytics_dashboard_url(analytics_dashboard, format: :json)
