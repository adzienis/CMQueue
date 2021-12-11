module Postgres
  module Views
    module QuestionState
      def self.create(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        CREATE OR REPLACE VIEW course_#{course_id}.question_states AS
          SELECT question_states.*
          FROM question_states
          INNER JOIN enrollments ON question_states.enrollment_id = enrollments.id 
          INNER JOIN roles ON enrollments.role_id = roles.id where roles.resource_type = 'Course' and roles.resource_id = #{course_id}
        SQL
        )
      end

      def self.destroy(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        DROP VIEW IF EXISTS course_#{course_id}.question_states
        SQL
        )
      end
    end
  end
end
