module Postgres
  module Views
    def self.create_views_schema(course_id)
      ActiveRecord::Base.connection.execute(
        <<-SQL
        CREATE SCHEMA IF NOT EXISTS course_#{course_id}
      SQL
      )
    end
  end
end