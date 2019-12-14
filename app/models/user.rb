class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable #, :confirmable
  
  has_many :group_memberships, foreign_key: "member_id"
  has_many :participating_groups, class_name: "Group", through: "group_memberships", source: "group"
  has_many :moderating_groups, class_name: "Group", foreign_key: "moderator_id"

  validates :full_name, presence: true
  validates :status, presence: true
  validates :votes_count, presence: true

  scope :order_by_votes_count, -> { order(votes_count: :desc) }
  scope :valid, -> { where.not(status: "deleted") }

  def current_vote
    X.queries.current_vote_of(self)
  end

  def trustee
    X.queries.trustee_of(self)
  end

  def query_groups(options)
    X.queries.groups_for(self, options)
  end

  def team
    X.queries.supreme_leader(self)
  end

  def dev_init
    X.dev_service.init(self)
    self
  end

  def set_email(email)
    self.email = email
    self
  end

  def set_color(color)
    self.color = color
    self
  end

  def set_name(name)
    self.full_name = name
    self
  end

  def set_password(password)
    self.password = password
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

  def name
    full_name
  end

  def set_deleted_at_now
    self.deleted_at = X.time_now
    self
  end  

  def set_deleted_status
    self.status = "deleted"
    self
  end

  def set_active_status
    self.status = "active"
    self
  end

  def set_email_nil
    set_email(nil)
    self
  end

  def active?
    status == "active"
  end
        
  def active_for_authentication?  
    super && active?
  end  

  def email_required?
    active?
  end
                    
  def inactive_message   
    active? ? super : :deleted_account  
  end  

  def present(options)
    X.presenter.present(self, options)
  end
end
