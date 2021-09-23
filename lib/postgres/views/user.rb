module Postgres
  module Views
    module User
      def self.create(course_id)

        ActiveRecord::Base.connection.execute(
          <<-SQL
        CREATE OR REPLACE VIEW course_#{course_id}.users AS
          SELECT users.*
          FROM users
          INNER JOIN enrollments ON users.id = enrollments.user_id 
          INNER JOIN roles ON enrollments.role_id = roles.id where roles.resource_type = 'Course' and roles.resource_id = #{course_id}
        SQL
        )
      end

      def self.destroy(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        DROP VIEW IF EXISTS course_#{course_id}.users
        SQL
        )
      end
    end
  end
end