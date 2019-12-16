class Services
  def recount_trusts(group)
    X.transaction do
      group.query_memberships.each do |membership|
        trust_count = X.queries.count_trust(membership)
        membership.trust_count = trust_count
        membership.save!
      end
    end
  end

  def delete_account(user)
    X.transaction do
      trusts_on = X.queries.trusts_on(user)
      trusts_of = X.queries.all_trusts_of({ user: user })

      trusts_on.each do |trust|
        trust.set_status_account_deleted
        trust.save!
      end

      trusts_of.each do |trust|
        trust.set_status_account_deleted
        trust.save!
      end

      user.set_deleted_at_now
      user.set_deleted_status
      user.set_email_nil
      user.save!
    end

    recount_trusts
    self
  end

  def join_group(group, users)
    users = Array(users)
    users.map do |user|
      if group.not_member?(user)
        membership = X.factory.build("group_membership")
        membership.group = group
        membership.member = user
        membership.start_trust_count
        membership.save!
      end
    end
    self
  end

  def trust_back(trust)
    trust.set_status_old
    trust.expire_now
    trust.save!
    self
  end
end