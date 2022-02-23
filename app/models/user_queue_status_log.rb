class UserQueueStatusLog < ApplicationRecord
  belongs_to :queue_status_log
  belongs_to :user
end
