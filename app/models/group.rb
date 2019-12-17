class Group < ApplicationRecord
  belongs_to :moderator, class_name: "User"

  has_many :gmembers, class_name: "GroupMembership"
  has_many :members, through: :gmembers do
    def active
      where(group_memberships: { status: "active" })
    end
   end

  scope :order_by_members_count, -> {  } #todo

  validates :name, presence: true

  def query_members(options = nil)
    X.queries.group_members(self, options)
  end

  def query_gmembers(a = {})
    a[:group] = self
    X.queries.gmembers(a)
  end

  def query_gmember(user)
    X.queries.find_gmember({ group: self, member: user })
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