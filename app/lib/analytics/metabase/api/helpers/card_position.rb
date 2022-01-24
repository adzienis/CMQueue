module Analytics
  module Metabase
    module API
      module Helpers
        class CardPosition
          def initialize(ordered_card:, row:, col:, size_x:, size_y:, series:[], visualization_settings: {}, parameter_mappings:[])
            @ordered_card = ordered_card
            @row = row
            @col = col
            @size_x = size_x
            @size_y = size_y
            @series = series
            @visualization_settings = visualization_settings
            @parameter_mappings = parameter_mappings
          end
          attr_reader :ordered_card, :row, :col, :size_x, :size_y, :series, :visualization_settings, :parameter_mappings
        end
      end
    end
  end
end