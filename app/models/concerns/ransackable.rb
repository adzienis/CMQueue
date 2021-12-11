module Ransackable
  extend ActiveSupport::Concern

  included do
    ransacker :created_at do
      Arel.sql("date(#{table_name}.created_at::timestamptz at time zone 'est')")
    end

    ransacker :updated_at do
      Arel.sql("date(#{table_name}.updated_at::timestamptz at time zone 'est')")
    end

    ransacker :discarded_at do
      Arel.sql("date(#{table_name}.discarded_at::timestamptz at time zone 'est')")
    end
  end
end
