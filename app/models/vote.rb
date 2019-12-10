class Vote < ApplicationRecord
  belongs_to :voter, class_name: "User"
  belongs_to :person, class_name: "User"

  scope :active, -> {  }
  scope :with_persons, ->(persons) { where(person: persons) }
  scope :with_voters, ->(voters) { where(voter: voters) }

  # status
  # power

  def set_detached
    self
  end
end