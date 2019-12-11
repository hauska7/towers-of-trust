class Queries
  def find_user(user_id)
    User.find(user_id)
  end

  def all_users_ordered_by_votes
    User.all.order_by_votes_count.to_a
  end

  def all_users
    User.all.to_a
  end

  def count_votes(user)
    people_behind(user).size
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

  def all_votes_of(user, order = nil)
    case order
    when nil
      Vote.with_voters(user).includes_all.to_a
    when "order_by_creation"
      Vote.with_voters(user).includes_all.order(created_at: :desc).to_a
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