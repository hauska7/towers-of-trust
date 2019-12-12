class Vote < ApplicationRecord
  belongs_to :voter, class_name: "User"
  belongs_to :person, class_name: "User"

  scope :active, -> { where(status: "active") }
  scope :valid, -> { where.not(status: "account_deleted") }
  scope :with_persons, ->(persons) { where(person: persons) }
  scope :with_voters, ->(voters) { where(voter: voters) }
  scope :includes_all, ->() { includes(:voter, :person) }

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