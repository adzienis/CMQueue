class Analytics::Metabase::Dashboards::UpdateLayout
  def initialize
  end

  def call
    {
      cards: [
        {id: 71,
         card_id: 40,
         row: 0,
         col: 8,
         sizeX: 3,
         sizeY: 3,
         series: [],
         visualization_settings: {},
         parameter_mappings: []},
        {
          id: 72,
          card_id: 39,
          row: 0,
          col: 5,
          sizeX: 3,
          sizeY: 3,
          series: [],
          visualization_settings: {},
          parameter_mappings: []
        },
        {
          id: 73,
          card_id: 41,
          row: 0,
          col: 11,
          sizeX: 3,
          sizeY: 3,
          series: [],
          visualization_settings: {},
          parameter_mappings: []
        },
        {
          id: 74,
          card_id: 43,
          row: 3,
          col: 8,
          sizeX: 3,
          sizeY: 3,
          series: [],
          visualization_settings: {},
          parameter_mappings: []
        },
        {
          id: 75,
          card_id: 44,
          row: 3,
          col: 11,
          sizeX: 3,
          sizeY: 3,
          series: [],
          visualization_settings: {},
          parameter_mappings: []
        },
        {
          id: 76,
          card_id: 46,
          row: 6,
          col: 0,
          sizeX: 9,
          sizeY: 4,
          series: [],
          visualization_settings: {},
          parameter_mappings: [
            {
              parameter_id: "280af9ca",
              card_id: 46,
              target: ["dimension", ["field", 162, {"join-alias": "Enrollments"}]]
            }
          ]
        },
        {
          id: 77,
          card_id: 47,
          row: 6,
          col: 9,
          sizeX: 9,
          sizeY: 4,
          series: [],
          visualization_settings: {
            "graph.dimensions": ["created_at"],
            series_settings: {
              count: {
                "line.missing": "zero",
                "line.marker_enabled": null,
                axis: null
              }
            },
            "graph.x_axis.scale": "timeseries",
            "graph.y_axis.auto_range": true,
            "graph.show_trendline": false,
            "graph.show_goal": false,
            "graph.show_values": false,
            "graph.metrics": ["count"]
          },
          parameter_mappings: []
        },
        {
          id: 78,
          card_id: 48,
          row: 10,
          col: 0,
          sizeX: 9,
          sizeY: 7,
          series: [],
          visualization_settings: {},
          parameter_mappings: [{parameter_id: "f3ec1598", card_id: 48, target: ["dimension", ["field", 364, null]]}]
        }, {id: 80, card_id: 42, row: 3, col: 5, sizeX: 3, sizeY: 3, series: [], visualization_settings: {}, parameter_mappings: []}, {id: 86, card_id: 53, row: 10, col: 9, sizeX: 9, sizeY: 7, series: [], visualization_settings: {}, parameter_mappings: [{parameter_id: "f3ec1598", card_id: 53, target: ["dimension", ["template-tag", "date"]]}]}, {id: 87, card_id: 54, row: 17, col: 0, sizeX: 18, sizeY: 8, series: [], visualization_settings: {}, parameter_mappings: [{parameter_id: "f3ec1598", card_id: 54, target: ["dimension", ["template-tag", "date"]]}]}, {id: 88, card_id: 55, row: 25, col: 0, sizeX: 18, sizeY: 7, series: [], visualization_settings: {}, parameter_mappings: [{parameter_id: "a6f6da08", card_id: 55, target: ["dimension", ["template-tag", "full_name"]]}]}, {id: 89, card_id: 56, row: 32, col: 0, sizeX: 18, sizeY: 7, series: [], visualization_settings: {}, parameter_mappings: [{parameter_id: "f3ec1598", card_id: 56, target: ["dimension", ["template-tag", "date"]]}]}
      ]
    }
  end
end
