# == Schema Information
#
# Table name: tags
#
#  id           :bigint           not null, primary key
#  course_id    :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  archived     :boolean          default(TRUE)
#  name         :text             default("")
#  description  :text             default("")
#  discarded_at :datetime
#
require 'pagy/extras/searchkick'

class Tag < ApplicationRecord
  include Discard::Model
  include Ransackable
  extend Pagy::Searchkick

  searchkick

  scope :search_import, -> { includes(:tag_groups) }

  def search_data
    {
      id: id,
      name: name,
      created_at: created_at,
      discarded_at: discarded_at,
      description: description,
      course_id: course_id,
      visibility: archived ? "hidden" : "visible",
      tag_groups: tag_groups.map(&:name)
    }
  end

  validates :name, presence: true

  scope :with_courses, ->(course_id) do
    where(course_id: course_id)
  end
  scope :archived, -> { where(archived: true) }
  scope :unarchived, -> { where(archived: false) }

  belongs_to :course

  has_many :group_members,
           -> { where(individual_type: "Tag") },
           foreign_key: :individual_id,
           as: :individual,
           inverse_of: :individual
  has_many :tag_groups,
           through: :group_members,
           as: :group,
           source: :group,
           source_type: "TagGroup",
           inverse_of: :tags

  has_and_belongs_to_many :questions

  after_commit do
    tag_groups.reindex
    self.reindex(refresh: true)
  end
end
