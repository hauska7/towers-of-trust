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

  scope :valid, -> { where.not(status: "deleted") }

  def current_trust(a)
    a[:truster] = self
    X.queries.current_trust(a)
  end

  def trustee(group)
    X.queries.trustee({ truster: self, group: group })
  end

  def query_groups(options)
    X.queries.groups_for(self, options)
  end

  def query_gmembers(a = {})
    query_group_memberships(a)
  end

  def query_group_memberships(a)
    a[:member] = self
    X.queries.group_memberships(a)
  end

  def group_membership(a)
    a[:member] = self
    X.queries.find_group_membership(a)
  end

  def dev_init
    X.dev_service.init(self)
    self
  end

  def set_email(email)
    self.email = email
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

  def present(options = nil)
    X.presenter.present(self, options)
  end
end
