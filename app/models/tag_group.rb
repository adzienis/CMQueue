class TagGroup < ApplicationRecord
  has_many :group_members, -> { where(group_type: "TagGroup") }, as: :group, foreign_key: :group_id, inverse_of: :group
  has_many :tags, through: :group_members, as: :individual, source: :individual, source_type: "Tag", inverse_of: :tag_groups

  belongs_to :course

  validates :name, presence: true
end
