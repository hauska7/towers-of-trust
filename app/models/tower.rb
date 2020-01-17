class Tower < ApplicationRecord
  belongs_to :owner, class_name: "GroupMembership"
  belongs_to :group

  validates :name, presence: true

  def set_name(name)
    self.name = name
    self
  end
end