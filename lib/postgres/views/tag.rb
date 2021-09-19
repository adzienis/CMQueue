module Postgres
  module Views
    module Tag
      def self.create(course_id)

        ActiveRecord::Base.connection.execute(
          <<-SQL
        CREATE OR REPLACE VIEW course_#{course_id}.tags AS
          #{::Tag.with_course(course_id).to_sql}
        SQL
        )
      end

      def self.destroy(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        DROP VIEW IF EXISTS course_#{course_id}.tags
        SQL
        )
      end
    end
  end
end