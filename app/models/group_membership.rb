class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :member, class_name: "User"
end