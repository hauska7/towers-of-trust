class Services
  def clean_up_trusts(group)
    X.transaction do
      gmembers = group.query_gmembers({ pagination: X.get_pagination("no_pagination") })
      gmembers.each do |gmember|
        trust_count = X.queries.count_trust(gmember)
        trustee = gmember.query_trustee
        gmember.trust_count = trust_count
        gmember.trustee = trustee
        gmember.save!
      end
    end
  end

  def clean_up_towers(group)
    X.transaction do
      gmembers = group.query_gmembers({ pagination: X.get_pagination("no_pagination") })

      gmembers.each do |gmember|
        top_gmember = X.queries.top_gmember_from_trust({ gmember: gmember })
        if top_gmember
          unless top_gmember.tower
            tower = X.factory.build("tower")
            tower.set_name(X.generate_tower_name(group))
            tower.group = group
            tower.owner = top_gmember
            tower.save!
            top_gmember.tower = tower
            top_gmember.save!
          else
            top_gmember.tower.owner = top_gmember
            top_gmember.tower.save!
          end

          gmember.tower = top_gmember.tower
          gmember.save!
        end
      end

      empty_towers = X.queries.query("towers", { group: group, empty: "true" })
      empty_towers.each(&:destroy!)
    end
  end

  def clean_up_gmembers_count(group)
    group.members_count = X.queries.count_gmembers(group)
    group.save!
  end

  def clean_up(groups = "all")
    if groups == "all"
      groups = X.queries.all_groups
    end

    groups = Array(groups)

    groups.each do |group|
      X.transaction do
        clean_up_trusts(group)
        clean_up_towers(group)
        clean_up_gmembers_count(group)
      end
    end
  end

  def delete_account(user)
    gmembers = user.query_gmembers

    X.transaction do
      gmembers.each do |gmember|
        delete_gmember(gmember, "dont_clean_up")
      end

      user.set_deleted_at_now
      user.set_deleted_status
      user.set_email_nil
      user.save!

      clean_up(gmembers.map(&:group))
    end
    self
  end

  def join_group(group, users)
    users = Array(users)
    X.transaction do
      users.map do |user|
        gmember = X.queries.find_gmember({ group: group, member: user, with_deleted: true })
        if gmember.nil?
          gmember = X.factory.build("gmember")
          gmember.group = group
          gmember.member = user
          gmember.set_status_active
          gmember.start_trust_count
          gmember.set_color X.generate_color
          gmember.save!
        elsif gmember.status_active?
          # procced
        elsif gmember.status_deleted?
          gmember.tower = nil
          gmember.set_status_active
          gmember.start_trust_count
          gmember.save!
        else fail
        end
      end

      clean_up_gmembers_count(group)
    end
    self
  end

  def trust_back(a, options)
    fail unless options == "dont_clean_up"

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
        truster.trustee = nil
        truster.save!
        trust.set_status_old
        trust.expire_now
        trust.save!
      end
    end
    self
  end

  def delete_gmember(gmember, options)
    fail unless options == "dont_clean_up"

    trusts_on = X.queries.trusts_on(gmember, { group: gmember.group })
    trusts_of = X.queries.trusts_of({ gmember: gmember })

    trusts_on.each do |trust|
      trust.set_status_old
      trust.save!
    end
    trusts_of.each do |trust|
      trust.set_status_old
      trust.save!
    end

    gmember.tower_id = nil
    gmember.set_status_deleted
    gmember.save!
    self
  end
end