module Analytics
  module Metabase
    module Questions
      class CreatedCurrentSemesterCount
        include Metabaseable

        def initialize(course:, database_id: mb.root_db.id, collection_id: nil, default_semester: Enrollment.default_semester)
          @database_id = database_id
          @course = course
          @collection_id = collection_id
          @default_semester = default_semester
        end

        def query
          <<~SQL
            select count(*) from #{course.mb_schema}.questions 
            inner join #{course.mb_schema}.enrollments on #{course.mb_schema}.enrollments.id = #{course.mb_schema}.questions.enrollment_id
            where {{semester}}
          SQL
        end

        def semester_field_id
          mb.schema_fields(table_name: "Enrollments", schema: course.mb_schema)["Semester"]["id"]
        end

        def call
          {
            name: "Questions Created This Semester",
            dataset_query: {
              type: "native",
              native: {
                query: query,
                "template-tags": {
                  semester: {
                    id: "b22e71db-d584-ddfb-33a9-6f0fc6209e2e",
                    name: "semester",
                    "display-name": "Semester",
                    type: "dimension",
                    dimension: ["field", semester_field_id, nil],
                    "widget-type": "category",
                    default: nil
                  }
                }
              },
              database: database_id
            },
            display: "scalar",
            description: nil,
            visualization_settings: {
              "graph.dimensions": ["created_at"],
              "graph.metrics": ["count"],
              column_settings: {"[\"name\",\"count\"]": {}},
              "table.columns": [{
                                  name: "count",
                                  fieldRef: ["field", "count", {"base-type": "type/BigInteger"}],
                                  enabled: true
                                }],
              "scalar.field": "count"
            },
            collection_id: collection_id
          }
        end

        private

        attr_reader :course, :default_semester, :collection_id, :database_id
      end
    end
  end
end
