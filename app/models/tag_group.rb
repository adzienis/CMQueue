class TagGroup < ApplicationRecord
  belongs_to :course

  validates :name, presence: true

  has_many :tags
end
