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

  def recount_towers(group)
    X.transaction do
      group.query_memberships.each do |membership|
        tower = X.queries.tower_from_trust({ group_membership: membership })
        membership.tower = tower
        membership.save!
      end
    end
  end

  def delete_account(user)
    X.transaction do
      trusts_on = X.queries.trusts_on(user)
      trusts_of = X.queries.all_trusts_of({ user: user })
      gmembers = user.query_gmembers
      groups = gmembers.map(&:group)

      trusts_on.each do |trust|
        trust.set_status_account_deleted
        trust.save!
      end

      trusts_of.each do |trust|
        trust.set_status_account_deleted
        trust.save!
      end

      gmembers.each do |gmember|
        X.services.delete_gmember(gmember)
      end

      user.set_deleted_at_now
      user.set_deleted_status
      user.set_email_nil
      user.save!
    end

    X.transaction do
      groups.each do |group|
        recount_trusts(group)
        recount_towers(group)
      end
    end
    self
  end

  def join_group(group, users)
    users = Array(users)
    users.map do |user|
      gmember = X.queries.find_gmember({ group: group, member: user, with_deleted: true })
      if gmember.nil?
        gmember = X.factory.build("group_membership")
        gmember.group = group
        gmember.member = user
        gmember.set_status_active
        gmember.start_trust_count
        gmember.set_color X.generate_color
        gmember.save!
      elsif gmember.status_active?
        # procced
      elsif gmember.status_deleted?
        gmember.set_status_active
        gmember.save!
      else fail
      end
    end
    self
  end

  def trust_back(a)
    if a.is_a?(Trust)
      truster = a.truster
    elsif a.is_a?(GroupMembership)
      truster = a
    else fail
    end

    X.transaction do
      trust = truster.current_trust
      if trust
        truster.tower = nil
        truster.save!
        trust.set_status_old
        trust.expire_now
        trust.save!
      end
    end
    self
  end

  def delete_gmember(gmember)
    #dependant_memberships = membership.query_dependant_memberships
    #X.transaction do
    #  dependant_memberships.each do |m|
    #    m.destroy!
    #  end
    #  membership.destroy!
    #end
    gmember.set_status_deleted
    gmember.save!
    self
  end
end