class Trust < ApplicationRecord
  belongs_to :truster, class_name: "GroupMembership"
  belongs_to :trustee, class_name: "GroupMembership"
  belongs_to :group, class_name: "Group"

  scope :active, -> { where(status: "active") }
  scope :valid, -> { where.not(status: "account_deleted") }
  scope :with_trustees, ->(trustees) { where(trustee: trustees) }
  scope :with_trusters, ->(trusters) { where(truster: trusters) }
  scope :with_truster_users, ->(users) { joins(:truster).where(truster: { member: users }) }
  scope :with_groups, ->(groups) { where(group: groups) }
  scope :includes_all, ->() { includes(:truster, :trustee, :group) }

  validates :status, presence: true

  def active?
    status == "active"
  end

  def expired?
    !expired_at.nil?
  end

  def set_status_old
    self.status = "old"
    self
  end

  def expire_now
    self.expired_at = X.time_now
    self
  end

  def set_status_active
    self.status = "active"
    self
  end

  def set_status_account_deleted
    self.status = "account_deleted"
    self
  end

  def set_reason(reason)
    #self.reason = reason
    self
  end

  def present_status
    status
  end

  def present_created_at
    created_at
  end
end