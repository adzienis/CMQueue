module Postgres
  module Views
    module Enrollment
      def self.create(course_id)

        ActiveRecord::Base.connection.execute(
          <<-SQL
        CREATE OR REPLACE VIEW course_#{course_id}.enrollments AS
          #{::Enrollment.with_courses(course_id).to_sql}
        SQL
        )
      end

      def self.destroy(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        DROP VIEW IF EXISTS course_#{course_id}.enrollments
        SQL
        )
      end
    end
  end
end