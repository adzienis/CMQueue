class Analytics::Dashboard < ApplicationRecord
  validates :data, :course_id, presence: true
  enum dashboard_type: [ :metabase ]

  belongs_to :course

end
