module Analytics
  module Metabase
    module Cards
      class OrderCardsOnDashboard
        include Metabaseable

        def initialize(dashboard:, card_positions:)
          @dashboard = dashboard
          @card_positions = card_positions
        end

        def call
          mb.put_dashboard_cards(dashboard_id: dashboard.id, json: json)
        end

        private

        def json
          {
            "cards": card_positions.map do |card_position|
              {
                id: card_position.ordered_card["id"],
                card_id: card_position.ordered_card["card"].id,
                row: card_position.row,
                col: card_position.col,
                sizeX: card_position.size_x,
                sizeY: card_position.size_y,
                series: card_position.series,
                visualization_settings: card_position.visualization_settings,
                parameter_mappings: card_position.parameter_mappings
              }
            end
          }
        end

        attr_reader :dashboard, :card_positions
      end
    end
  end
end