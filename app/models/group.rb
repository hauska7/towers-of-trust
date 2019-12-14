class Group < ApplicationRecord
  belongs_to :moderator, class_name: "User"

  has_many :group_memberships
  has_many :members, through: :group_memberships

  validates :name, presence: true

  def query_members(options)
    X.queries.group_members(self, options)
  end

  def member?(user)
    X.queries.group_member?(self, user)
  end

  def set_name(name)
    self.name = name
    self
  end

  def present
    X.presenter.present(self)
  end
end