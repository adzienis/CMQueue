module Analytics
  module Metabase
    module Cards
      class OrderDefaultCardsInCourse
        def initialize(course:)
          @course = course
        end

        def call
          card_positions = config.map do |_, entry|
            card_name = entry["name"]
            ordered_card = course.base_dashboard.ordered_cards.find{|v| v["card"].name == card_name}

            Analytics::Metabase::API::Helpers::CardPosition.new(
              ordered_card: ordered_card,
              row: entry["row"],
              col: entry["col"],
              size_x: entry["sizeX"],
              size_y: entry["sizeY"]
            )
          end

          Analytics::Metabase::Cards::OrderCardsOnDashboard.new(dashboard: course.base_dashboard, card_positions: card_positions).call
        end

        def config
          @config ||= YAML.load(File.read(file_path))
        end

        def file_path
          "config/analytics/metabase/base_dashboard.yml"
        end

        private

        attr_reader :course
      end
    end
  end
end