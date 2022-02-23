class QueueStatusLog < ApplicationRecord
  belongs_to :course
  has_many :user_queue_status_logs, dependent: :destroy
  has_many :users, through: :user_queue_status_logs
end
