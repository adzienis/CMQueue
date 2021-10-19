module Postgres
  module Views
    module Role
      def self.create(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        CREATE OR REPLACE VIEW course_#{course_id}.roles AS
          SELECT *
          FROM roles
          WHERE resource_type = 'Course' and resource_id = #{course_id}
        SQL
        )
      end

      def self.destroy(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        DROP VIEW IF EXISTS course_#{course_id}.roles
        SQL
        )
      end
    end
  end
end