class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :member, class_name: "User"
  belongs_to :tower, class_name: "GroupMembership", optional: true

  has_many :memmberships_in_this_tower, class_name: "GroupMembership", foreign_key: "tower_id"

  validates :trust_count, presence: true

  scope :active, -> { where(status: "active") }
  scope :order_by_trust_count, -> { order(trust_count: :desc) }

  def trusting?(trustee)
    X.queries.trusting?({ trustee: trustee, truster: self })
  end

  def current_trust
    X.queries.current_trust({ group_membership: self })
  end

  def trustee
    X.queries.trustee({ group_membership: self })
  end

  def query_dependant_memberships
    X.queries.dependant_group_memberships(self)
  end

  def status_active?
    status == "active"
  end

  def status_deleted?
    status == "deleted"
  end

  def set_status_active
    self.status = "active"
    self
  end

  def set_status_deleted
    self.status = "deleted"
    self
  end

  def set_trust_count(trust_count)
    self.trust_count = trust_count
    self
  end

  def start_trust_count
    set_trust_count(0)
    self
  end

  def set_color(color)
    self.color = color
    self
  end

  def member_name
    member.name
  end

  def group_name
    group.name
  end

  def present(options = nil)
    X.presenter.present(self, options)
  end
end