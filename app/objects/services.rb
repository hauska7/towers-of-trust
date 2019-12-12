class Services
  def recount_votes
    X.transaction do
      X.queries.all_users.each do |u|
        votes_count = X.queries.count_votes(u)
        u.votes_count = votes_count
        u.save!
      end
    end
  end

  def delete_account(user)
    X.transaction do
      votes_on = X.queries.votes_on(user)
      votes_of = X.queries.all_votes_of(user)

      votes_on.each do |vote|
        vote.set_status_account_deleted
        vote.save!
      end

      votes_of.each do |vote|
        vote.set_status_account_deleted
        vote.save!
      end

      user.set_deleted_at_now
      user.set_deleted_status
      user.set_email_nil
      user.save!
    end

    recount_votes
  end
end