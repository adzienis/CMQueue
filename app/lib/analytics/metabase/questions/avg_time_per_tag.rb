class Analytics::Metabase::Questions::AvgTimePerTag
  def initialize(database_id:, course_schema:, collection_id: nil)
    @database_id = database_id
    @course_schema = course_schema
    @collection_id = collection_id
  end

  def call
    {
      "name": "Avg Time Per Tag",
      "dataset_query": {
        "type": "native",
        "native": {
          "query": "SELECT EXTRACT(epoch from avg(subquery.created_at - subquery_min.created_at)) time_to_resolve, " +
            "#{course_schema}.tags.id, count(#{course_schema}.questions.*) questions_count,#{course_schema}.tags.name" +
            " FROM #{course_schema}.questions " +
            "JOIN LATERAL ((SELECT #{course_schema}.question_states.created_at FROM #{course_schema}.question_states " +
            " WHERE (id in (SELECT max(id) FROM #{course_schema}.question_states " +
            "WHERE (question_id = #{course_schema}.questions.id and state = 2))))) subquery ON true " +
            "JOIN LATERAL ((SELECT #{course_schema}.question_states.created_at FROM #{course_schema}.question_states " +
            "WHERE (id in (SELECT max(id) FROM #{course_schema}.question_states " +
            "WHERE (question_id = #{course_schema}.questions.id and state = 1))))) subquery_min ON true " +
            "inner join #{course_schema}.questions_tags on " +
            "#{course_schema}.questions_tags.question_id = #{course_schema}.questions.id " +
            "inner join #{course_schema}.tags on #{course_schema}.questions_tags.tag_id = #{course_schema}.tags.id " +
            "group by #{course_schema}.tags.id, #{course_schema}.tags.name order by time_to_resolve DESC ",
          "template-tags": {}
        },
        "database": database_id
      },
      "display": "bar",
      "description": nil,
      "visualization_settings": {
        "graph.metrics": ["time_to_resolve", "questions_count"],
        "graph.dimensions": ["name"],
        "graph.show_values": true },
      "collection_id": collection_id,
    }
  end

  private

  attr_reader :database_id, :course_schema, :collection_id

end
