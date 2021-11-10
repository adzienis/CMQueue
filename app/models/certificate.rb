# == Schema Information
#
# Table name: certificates
#
#  id         :bigint           not null, primary key
#  course_id  :bigint           not null
#  data       :binary
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Certificate < ApplicationRecord
  belongs_to :course
end
