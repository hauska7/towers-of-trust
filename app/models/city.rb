class City < ApplicationRecord
  def self.build(attributes:, user:)
    result = new(attributes)
    result.user = user
    result
  end

  def self.build_template
    new
  end

  has_many :users
  belongs_to :user

  def full_presentation
    "#{name}, #{state}, #{country}"
  end
end
