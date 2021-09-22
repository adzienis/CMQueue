module Postgres
  module Views
    module Course
      def self.create(course_id)

        ActiveRecord::Base.connection.execute(
          <<-SQL
        CREATE OR REPLACE VIEW course_#{course_id}.courses AS
          SELECT *
          FROM courses
          WHERE id = #{course_id}
        SQL
        )
      end

      def self.destroy(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        DROP VIEW IF EXISTS course_#{course_id}.courses
        SQL
        )
      end
    end
  end
end