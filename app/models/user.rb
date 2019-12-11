class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable #, :confirmable

  validates :full_name, presence: true
  validates :votes_count, presence: true

  def current_vote
    X.queries.current_vote_of(self)
  end

  def set_email(email)
    self.email = email
    self
  end

  def set_default_password
    fail unless X.test?

    self.password = "123456"
    self
  end

  def set_name(name)
    self.full_name = name
    self
  end

  def start_votes_count
    set_votes_count(0)
    self
  end

  def set_votes_count(votes_count)
    self.votes_count = votes_count
    self
  end

  def add_votes_count(number)
    self.votes_count = votes_count + number
    self
  end

  def name
    full_name
  end

  def soft_delete  
    self.deleted_at = X.time_now
    save!
    self
  end  
        
  def active_for_authentication?  
    super && !deleted_at  
  end  
                    
  def inactive_message   
    !deleted_at ? super : :deleted_account  
  end  
end
