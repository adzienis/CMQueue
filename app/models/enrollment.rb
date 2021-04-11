class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  enum role: %i[student ta instructor]
end
