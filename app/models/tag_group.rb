class TagGroup < ApplicationRecord
  has_many :group_members, ->{ where(group_type: "TagGroup")},  foreign_key: :group_id
  has_many :tags, through: :group_members, source: :individual, source_type: "Tag"

  belongs_to :course

  validates :name, presence: true
end
