class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :member, class_name: "User"

  validates :trust_count, presence: true

  scope :order_by_trust_count, -> { order(trust_count: :desc) }

  def tower
    X.queries.supreme_leader(self)
  end

  def current_trust
    X.queries.current_trust({ group_membership: self })
  end

  def trustee
    X.queries.trustee({ group_membership: self })
  end

  def set_trust_count(trust_count)
    self.trust_count = trust_count
    self
  end

  def start_trust_count
    set_trust_count(0)
    self
  end

  def member_name
    member.name
  end

  def group_name
    group.name
  end

  def present_as_member
    X.presenter.present(self, "user")
  end

  def present_as_group
    X.presenter.present(self, "group")
  end
end