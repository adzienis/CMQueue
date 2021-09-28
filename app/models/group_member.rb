class GroupMember < ApplicationRecord
  belongs_to :individual, polymorphic: true, inverse_of: :group_members
  belongs_to :group, polymorphic: true, inverse_of: :group_members

end
