# == Schema Information
#
# Table name: group_members
#
#  id              :bigint           not null, primary key
#  individual_id   :integer
#  individual_type :string
#  group_id        :integer
#  group_type      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class GroupMember < ApplicationRecord
  belongs_to :individual, polymorphic: true, inverse_of: :group_members
  belongs_to :group, polymorphic: true, inverse_of: :group_members
end
