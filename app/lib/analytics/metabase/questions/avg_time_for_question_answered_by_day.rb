class Analytics::Metabase::Questions::AvgTimeForQuestionAnsweredByDay
  include Metabaseable

  def initialize(database_id: mb.root_db.id, course:,  collection_id: nil,
                 default_semester: Enrollment.default_semester)
    @database_id = database_id
    @course = course
    @collection_id = collection_id
    @default_semester = default_semester
  end

  def call
    {
      "name": "Avg Time To Answer By Day",
      "dataset_query": {
        "type": "native",
        "native": {
          "query": query,
            "template-tags": {
            "semester": {
              "name": "semester",
              "display-name": "Semester",
              "type": "dimension",
              "dimension": ["field", semester_field_id, nil],
              "widget-type": "category",
              "default": nil
            }
          }
        },
        "database": database_id
      },
      "display": "line",
      "description": nil,
      "visualization_settings": {
        "series_settings": {
          "questions_count": {
            "title": "Questions Count"
          },
          "total_time": {
            "title": "Avg Time To Answer"
          }
        },
        "graph.dimensions": ["created_at"],
        "graph.metrics": ["questions_count", "total_time"]
      },
      collection_id: collection_id
    }
  end

  private

  attr_accessor :database_id, :course, :filters, :collection_id, :date_field_id, :full_name_field_id, :default_semester

  def semester_field_id
    mb.schema_fields(table_name: "Enrollments", schema: course.mb_schema)["Semester"]["id"]
  end

  def query
    <<~SQL
      SELECT COUNT(*) questions_count,
      questions.created_at::DATE,
      extract(epoch from avg(subquery.created_at - subquery_min.created_at)) total_time FROM #{course.mb_schema}.questions
      INNER JOIN #{course.mb_schema}.enrollments ON #{course.mb_schema}.enrollments.id = #{course.mb_schema}.questions.enrollment_id
      INNER JOIN #{course.mb_schema}.users ON #{course.mb_schema}.users.id = #{course.mb_schema}.enrollments.user_id
      JOIN LATERAL ((SELECT #{course.mb_schema}.question_states.created_at FROM #{course.mb_schema}.question_states WHERE
      (id IN (SELECT max(id) FROM #{course.mb_schema}.question_states 
      WHERE (question_id = #{course.mb_schema}.questions.id and state = 2)))))
        subquery ON true JOIN LATERAL ((SELECT #{course.mb_schema}.question_states.created_at 
      FROM #{course.mb_schema}.question_states
      WHERE (id in (SELECT max(id) FROM #{course.mb_schema}.question_states
      WHERE (question_id = #{course.mb_schema}.questions.id and state = 1))))) subquery_min ON true
      WHERE {{semester}}
      GROUP BY #{course.mb_schema}.questions.created_at::DATE
      ORDER BY #{course.mb_schema}.questions.created_at::DATE ASC
    SQL
  end
end

