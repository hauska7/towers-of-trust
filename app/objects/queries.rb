class Queries
  def find_user(user_id)
    User.valid.find_by(id: user_id)
  end

  def find_group(group_id)
    Group.find_by(id: group_id)
  end

  def find_group_membership(a)
    if a.is_a?(Hash)
      if a.key?(:group) && a.key?(:member)
        GroupMembership.where(group: a[:group], member: a[:member]).first
      else fail
      end
    else
      GroupMembership.find_by(id: a)
    end
  end

  def find_trust(trust_id)
    Vote.valid.find_by(id: trust_id)
  end

  def find_user!(user_id)
    find_user(user_id) || X.ex.not_found!
  end

  def find_group!(group_id)
    find_group(group_id) || X.ex.not_found!
  end

  def find_group_membership!(a)
    find_group_membership(a) || X.ex.not_found!
  end

  def find_trust!(trust_id)
    find_trust(trust_id) || X.ex.not_found!
  end

  def all_users
    User.valid.all.to_a
  end

  def all_groups(options = nil)
    case options
    when nil
      Group.all.order_by_members_count.to_a
    when "order_by_members_count"
      Group.all.order_by_members_count.to_a
    else fail
    end
  end

  def groups_for(user, options)
    case options
    when "moderating"
      user.moderating_groups.to_a
    when "participating"
      user.participating_groups.to_a
    else fail
    end
  end

  def group_memberships(a)
    if a.is_a?(Hash)
      if a.key?(:group)
        case a[:order]
        when nil
          a[:group].memberships.order_by_trust_count.to_a
        when "order_by_trust_count"
          a[:group].memberships.order_by_trust_count.to_a
        else fail
        end
      elsif a.key?(:user)
        case a[:order]
        when "order_by_trust_count"
          a[:user].group_memberships.order_by_trust_count.to_a
        else fail
        end
      else fail
      end
    else fail
    end
  end

  def group_members(group, options = nil)
    case options
    when nil
      group.members.to_a
    else fail
    end
  end

  def all_group_members?(group, users)
    all_members = group_members(group)
    users.all? { |user| all_members.include?(user) }
  end

  def group_member?(group, user)
    all_group_members?(group, [user])
  end

  def not_group_member?(group, user)
    !group_member?(group, user)
  end

  def count_trust(a)
    if a.is_a?(GroupMembership)
      people_behind(a.member, a.group).size
    elsif a.is_a?(Hash)
      if a.key?(:user) && a.key?(:group)
        people_behind(a[:user], a[:group]).size
      else fail
      end
    else fail
    end
  end

  def supreme_leader(a)
    if a.is_a?(GroupMembership)
      user = a.member
      group = a.group
      result = nil
      tmp = user.trustee(group)
      while !tmp.nil? && tmp != result
        result = tmp
        tmp = result.trustee(group)
      end
      result
    else fail
    end
  end

  def trusts_on(users, options)
    group = options.fetch(:group)

    case options[:order]
    when nil
      Vote.active.with_persons(users).with_groups(group).includes_all.to_a
    when "order_by_creation"
      Vote.active.with_persons(users).with_groups(group).includes_all.order(created_at: :desc).to_a
    else fail
    end
  end

  def current_trust(a)
    if a.is_a?(Hash)
      if a.key?(:group_membership)
        Vote.active.with_voters(a[:group_membership].member).with_groups(a[:group_membership].group).first
      elsif a.key?(:truster) && a.key?(:group)
        Vote.active.with_voters(a[:truster]).with_groups(a[:group]).first
      else fail
      end
    else fail
    end
  end

  def trustee(a)
    if a.is_a?(Hash)
      if a.key?(:group_membership)
        current_trust(a)&.trustee
      elsif a.key?(:truster) && a.key?(:group)
        current_trust(a)&.trustee
      else fail
      end
    else fail
    end
  end

  def all_trusts_of(a)
    if a.is_a?(Hash)
      if a.key?(:user)
        if !a.key?(:group)
          Vote.valid.with_voters(a[:user]).includes_all.to_a
        elsif a.key?(:group)
          case a[:order]
          when nil
            Vote.valid.with_voters(a[:user]).with_groups(a[:group]).includes_all.to_a
          when "order_by_creation"
            Vote.valid.with_voters(a[:user]).with_groups(a[:group]).includes_all.order(created_at: :desc).to_a
          else fail
          end
        else fail
        end
      else fail
      end
    else fail
    end
  end

  def people_behind(user, group)
    result = []
    tmp = [user]
    while tmp.present?
      tmp = trusts_on(tmp, { group: group }).map { |trust| trust.truster }
      tmp.select! { |user| !result.include?(user) }
      result.concat tmp
    end
    result
  end

  def supports?(whom, who, group)
    people_behind(whom, group).include?(who)
  end
end