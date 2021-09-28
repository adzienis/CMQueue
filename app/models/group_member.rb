class GroupMember < ApplicationRecord
  belongs_to :individual, polymorphic: true
  belongs_to :group, polymorphic: true

end
