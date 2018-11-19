class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :city, optional: true
  has_many :cities, class_name: "City"
  has_many :participations
  has_many :meetings, through: :participations

  validates :full_name, presence: true

  def self.build(full_name:, password:, email:)
    new(full_name: full_name, password: password, email: email)
  end

  def self.active_and_in_city(city_id:)
    where(deleted_at: nil).where(city_id: city_id)
  end

  def presentation_for_meeting
    "#{full_name} #{email} #{phone}"
  end

  def soft_delete  
    self.deleted_at = Time.current
    save!
    self
  end  
        
  def active_for_authentication?  
    super && !deleted_at  
  end  
                    
  # provide a custom message for a deleted account   
  def inactive_message   
    !deleted_at ? super : :deleted_account  
  end  
end
