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

  def votes_on(users)
    Vote.active.with_persons(users).to_a
  end

  def current_vote_of(user)
    Vote.active.with_voters(user).first
  end

  def all_votes_of(user)
    Vote.with_voters(user).to_a
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