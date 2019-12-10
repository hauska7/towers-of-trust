class Queries
  def find_user(user_id)
    User.find(user_id)
  end

  def all_users_ordered_by_votes
    User.all.to_a
  end

  def votes_on(user)
    Vote.active.with_persons(user).to_a
  end

  def all_votes_of(user)
    Vote.with_voters(user).to_a
  end

  def people_behind(user)
    #votes_on(user).each do |vote|

    #end
    #votes = votes_on(user)
    #childs_to_return = []
    #while childs_to_visit.present?
    #  current_node = childs_to_visit.shift
    #  childs_to_return << current_node
    #  childs_to_visit.concat(current_node.children)
    #end
    #childs_to_return
    fail
  end
end