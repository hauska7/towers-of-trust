class Vote < ApplicationRecord
  belongs_to :voter, class_name: "User"
  belongs_to :person, class_name: "User"

  scope :active, -> { where(status: "active") }
  scope :with_persons, ->(persons) { where(person: persons) }
  scope :with_voters, ->(voters) { where(voter: voters) }

  validates :status, presence: true

  def active?
    status == "active"
  end

  def expired?
    !expired_at.nil?
  end

  def make_old
    self.status = "old"
    self
  end

  def expire_now
    self.expired_at = X.time_now
    self
  end

  def set_reason(reason)
    #self.reason = reason
    self
  end

  def set_detached
    self
  end
end