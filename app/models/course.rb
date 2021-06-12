class Course < ApplicationRecord

  resourcify

  has_many :enrollments
  has_many :users, through: :enrollments
  #has_and_belongs_to_many :users
  #has_many :enrollments, dependent: :destroy
  #has_many :questions, through: :enrollments
  has_many :questions
  has_many :tags

  before_create do

    puts "creating --------------------------------------"
    self.ta_code = SecureRandom.urlsafe_base64(6) if !self.ta_code
    self.student_code = SecureRandom.urlsafe_base64(6) if !self.student_code
    self.instructor_code = SecureRandom.urlsafe_base64(6) if !self.instructor_code
  end

  after_update do
    QueueChannel.broadcast_to self, {
      invalidate: ['courses', id, 'open_status']
    }
  end

end
