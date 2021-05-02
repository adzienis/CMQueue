class Course < ApplicationRecord
  resourcify

  has_and_belongs_to_many :users
  #has_many :enrollments, dependent: :destroy
  #has_many :users, through: :enrollments
  has_many :questions
  has_many :tags

  after_update do

    ActionCable.server.broadcast "react-students", {
      invalidate: ['courses', self.id, 'open']
    }
  end

end
