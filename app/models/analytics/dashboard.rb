# == Schema Information
#
# Table name: analytics_dashboards
#
#  id         :bigint           not null, primary key
#  data       :jsonb
#  course_id  :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Analytics::Dashboard < ApplicationRecord
  validates :data, :course_id, presence: true
  enum dashboard_type: [:metabase]

  belongs_to :course
end
