# == Schema Information
#
# Table name: courses_registrations
#
#  id            :bigint           not null, primary key
#  name          :text             not null
#  approved      :boolean          default(FALSE)
#  instructor_id :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Courses::Registration < ApplicationRecord
  extend Pagy::Searchkick
  searchkick
  belongs_to :instructor, class_name: "User", foreign_key: :instructor_id

  def search_data
    {
      id: id,
      name: name,
      created_at: created_at,
      updated_at: updated_at,
      approved: approved
    }
  end
end
