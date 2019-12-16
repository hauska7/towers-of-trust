class Group < ApplicationRecord
  belongs_to :moderator, class_name: "User"

  has_many :memberships, class_name: "GroupMembership"
  has_many :members, through: :memberships

  scope :order_by_members_count, -> {  } #todo

  validates :name, presence: true

  def query_members(options = nil)
    X.queries.group_members(self, options)
  end

  def query_memberships(a = {})
    a[:group] = self
    X.queries.group_memberships(a)
  end

  def query_membership(user)
    X.queries.find_group_membership({ group: self, member: user })
  end

  def all_members?(users)
    X.queries.all_group_members?(self, users)
  end

  def member?(user)
    X.queries.group_member?(self, user)
  end

  def not_member?(user)
    X.queries.not_group_member?(self, user)
  end

  def set_name(name)
    self.name = name
    self
  end

  def present
    X.presenter.present(self)
  end
end