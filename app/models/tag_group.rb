# == Schema Information
#
# Table name: tag_groups
#
#  id          :bigint           not null, primary key
#  course_id   :bigint           not null
#  name        :string           not null
#  description :text             default("")
#  validations :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "pagy/extras/searchkick"

class TagGroup < ApplicationRecord
  extend Pagy::Searchkick

  searchkick

  scope :search_import, -> { includes(:tags) }

  def search_data
    {
      id: id,
      name: name,
      description: description,
      course_id: course_id,
      created_at: created_at,
      tags: tags.map(&:name)
    }
  end
  has_many :group_members, -> { where(group_type: "TagGroup") }, as: :group, foreign_key: :group_id, inverse_of: :group
  has_many :tags, through: :group_members, as: :individual, source: :individual, source_type: "Tag", inverse_of: :tag_groups

  belongs_to :course

  validates :name, presence: true

  after_commit do
    reindex(refresh: true)
  end
end
