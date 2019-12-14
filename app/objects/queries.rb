class Queries
  def find_user(user_id)
    User.valid.find_by(id: user_id)
  end

  def find_group(group_id)
    Group.find_by(id: group_id)
  end

  def find_group_membership(a)
    if a.is_a?(Hash)
      GroupMembership.where(group: a[:group], member: a[:member]).first
    else
      GroupMembership.find_by(id: a)
    end
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

  def all_users_ordered_by_votes
    User.all.valid.order_by_votes_count.to_a
  end

  def all_users
    User.valid.all.to_a
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

  def group_members(group, options = nil)
    case options
    when nil
      group.members.order_by_votes_count.to_a
    when "order_by_votes_count"
      group.members.order_by_votes_count.to_a
    else fail
    end
  end

  def group_member?(group, user)
    group_members(group).include?(user)
  end

  def count_votes(user)
    people_behind(user).size
  end

  def supreme_leader(user)
    result = nil
    tmp = user.trustee
    while !tmp.nil? && tmp != result
      result = tmp
      tmp = result.trustee
    end
    result
  end

  def votes_on(users, order = nil)
    case order
    when nil
      Vote.active.with_persons(users).includes_all.to_a
    when "order_by_creation"
      Vote.active.with_persons(users).includes_all.order(created_at: :desc).to_a
    else fail
    end
  end

  def current_vote_of(user)
    Vote.active.with_voters(user).first
  end

  def trustee_of(user)
    user.current_vote&.person
  end

  def all_votes_of(user, order = nil)
    case order
    when nil
      Vote.valid.with_voters(user).includes_all.to_a
    when "order_by_creation"
      Vote.valid.with_voters(user).includes_all.order(created_at: :desc).to_a
    else fail
    end
  end

  def people_behind(user)
    result = []
    tmp = [user]
    while tmp.present?
      tmp = votes_on(tmp).map { |vote| vote.voter }
      tmp.select! { |user| !result.include?(user) }
      result.concat tmp
    end
    result
  end

  def supports?(whom, who)
    people_behind(whom).include?(who)
  end
end