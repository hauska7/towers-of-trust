class Meeting < ApplicationRecord
  def self.build(users:, city:)
    meeting = new(status: "didnt_happen")
    meeting.city = city 
    meeting.users << users
    meeting
  end

  belongs_to :city
  has_many :participations
  has_many :users, through: :participations

  def participants
    users
  end

  def title_presentation
    "#{created_at.to_date} #{status}"
  end

  def participant?(user)
    users.include?(user)
  end

  def set_happened
    self.status = "happened"
    self
  end

  def happened?
    status == "happened"
  end
end
