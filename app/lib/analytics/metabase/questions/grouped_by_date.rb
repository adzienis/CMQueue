class Analytics::Metabase::Questions::GroupedByDate
  include Metabaseable

  def initialize(course:, database_id: mb.root_db.id, collection_id: nil, default_semester: "F21")
    @database_id = database_id
    @course = course
    @collection_id = collection_id
    @default_semester = default_semester
  end

  def query
    <<~SQL
      select #{course.mb_schema}.questions.created_at::date, count(*) from #{course.mb_schema}.questions 
      inner join #{course.mb_schema}.enrollments on 
      #{course.mb_schema}.enrollments.id = #{course.mb_schema}.questions.enrollment_id where {{date}} and {{semester}}
      group by #{course.mb_schema}.questions.created_at::date
    SQL
  end

  def call
    {
      name: "Questions Grouped By Date",
      dataset_query: {
        type: "native",
        native: {
          query: query,
          "template-tags": {
            date: {
              id: "3252771c-119b-8e8c-5168-c6f07345eb87",
              name: "date",
              "display-name": "Date",
              type: "dimension",
              dimension: ["field", metabase.schema_fields(table_name: "Questions", schema: course.mb_schema)["Created At"]["id"], nil],
              "widget-type": "date/all-options",
              required: false
            },
            semester: {
              id: "0ff46fb5-3703-8338-841b-eff198c8d712",
              name: "semester",
              "display-name": "Semester",
              type: "dimension",
              dimension: ["field", metabase.schema_fields(table_name: "Enrollments", schema: course.mb_schema)["Semester"]["id"], nil],
              "widget-type": "category",
              default: default_semester
            }
          }
        },
        database: database_id
      },
      display: "line",
      description: nil,
      visualization_settings: {
        "graph.dimensions": ["created_at"],
        "graph.metrics": ["count"]
      },
      collection_id: collection_id
    }
  end

  private

  attr_reader :database_id, :course, :collection_id, :default_semester
end
