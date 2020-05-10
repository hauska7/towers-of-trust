class Tower < ApplicationRecord
  belongs_to :owner, class_name: "GroupMembership"
  belongs_to :group
  has_many :group_memberships

  validates :name, presence: true

  def set_name(name)
    self.name = name
    self
  end

  def color
    "#e9e0f9"
  end

  def present
    name
  end
end