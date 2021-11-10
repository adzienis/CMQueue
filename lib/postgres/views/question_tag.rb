module Postgres
  module Views
    module QuestionTag
      def self.create(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        CREATE OR REPLACE VIEW course_#{course_id}.questions_tags AS
          SELECT questions_tags.*
          FROM questions_tags
          INNER JOIN questions ON questions_tags.question_id = questions.id
          WHERE questions.course_id = #{course_id}
        SQL
        )
      end

      def self.destroy(course_id)
        ActiveRecord::Base.connection.execute(
          <<-SQL
        DROP VIEW IF EXISTS course_#{course_id}.questions_tags
        SQL
        )
      end
    end
  end
end