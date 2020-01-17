class Queries
  def find_user(user_id)
    User.valid.find_by(id: user_id)
  end

  def find_group(group_id)
    Group.find_by(id: group_id)
  end

  def find_gmember(a)
    if a.is_a?(Hash)
      if a.key?(:group) && a.key?(:member)
        if a.fetch(:with_deleted, false)
          GroupMembership.where(group: a[:group], member: a[:member]).first
        else
          GroupMembership.active.where(group: a[:group], member: a[:member]).first
        end
      else fail
      end
    else
      GroupMembership.active.find_by(id: a)
    end
  end

  def find_trust(trust_id)
    Trust.valid.find_by(id: trust_id)
  end

  def find_trust_block(trust_block_id)
    Trust.block.find_by(id: trust_block_id)
  end

  def find_user!(user_id)
    find_user(user_id) || X.ex.not_found!
  end

  def find_group!(group_id)
    find_group(group_id) || X.ex.not_found!
  end

  def find_gmember!(a)
    find_gmember(a) || X.ex.not_found!
  end

  def find_trust!(trust_id)
    find_trust(trust_id) || X.ex.not_found!
  end

  def find_trust_block!(trust_block_id)
    find_trust_block(trust_block_id) || X.ex.not_found!
  end

  def query(what, a)
    case what
    when "trust_block"
      if a.key?(:trustee) && a.key?(:truster)
        Trust.where(status: "block", trustee: a[:trustee], truster: a[:truster]).first
      else fail
      end
    else fail
    end
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

  def gmembers(a)
    if a.is_a?(Hash)
      if a.key?(:group)
        case a[:order]
        when nil
          a[:group].gmembers.active.order_by_trust_count.paginate(a[:pagination]).to_a
        when "order_by_trust_count"
          a[:group].gmembers.active.order_by_trust_count.paginate(a[:pagination]).to_a
        when "joined_at_desc"
          a[:group].gmembers.active.order(created_at: :desc).paginate(a[:pagination]).to_a
        else fail
        end
      elsif a.key?(:member)
        case a[:order]
        when nil
          a[:member].gmembers.active.order_by_trust_count.to_a
        when "order_by_trust_count"
          a[:member].gmembers.active.order_by_trust_count.to_a
        when "joined_at_desc"
          a[:member].gmembers.active.order(created_at: :desc).to_a
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
      group.members.active.to_a
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
      trusting_gmembers_from_trust({ gmember: a }).size
    else fail
    end
  end

  def count_gmembers(group)
    group.gmembers.active.count
  end

  def top_gmember_from_trust(a)
    if a.is_a?(Hash)
      if a.key?(:gmember)
        gmember = a[:gmember]
        result = nil
        tmp = current_trust({ gmember: gmember })&.trustee
        while !tmp.nil? && tmp != result
          result = tmp
          tmp = current_trust({ gmember: result })&.trustee
        end
        result
      else fail
      end
    else fail
    end
  end

  def tower_top_down(a)
    if a.is_a?(Hash)
      if a.key?(:gmember)
        gmember = a[:gmember]
        result = []
        tower_top = gmember.tower_top
        current = gmember.trustee
        while !current.nil? && current != tower_top
          result << current
          current = current.trustee
        end
        result << tower_top if tower_top
        result.reverse
      else fail
      end
    else fail
    end
  end

  def trusts_on(gmembers, options)
    group = options.fetch(:group)

    case options[:order]
    when nil
      Trust.active.with_trustees(gmembers).with_groups(group).includes_all.to_a
    when "order_by_creation"
      Trust.active.with_trustees(gmembers).with_groups(group).includes_all.order(created_at: :desc).to_a
    else fail
    end
  end

  def current_trust(a)
    if a.is_a?(Hash)
      if a.key?(:gmember)
        Trust.active.with_trusters(a[:gmember]).with_groups(a[:gmember].group).first
      elsif a.key?(:truster) && a.key?(:group)
        Trust.active.with_trusters(a[:truster]).with_groups(a[:group]).first
      else fail
      end
    else fail
    end
  end

  def trustee_from_trust(a)
    if a.is_a?(Hash)
      if a.key?(:gmember)
        current_trust(a)&.trustee
      elsif a.key?(:truster) && a.key?(:group)
        current_trust(a)&.trustee
      else fail
      end
    else fail
    end
  end

  def trusts_of(a)
    if a.is_a?(Hash)
      if a.key?(:gmember)
        if !a.key?(:group)
          Trust.valid.with_trusters(a[:gmember]).includes_all.to_a
        elsif a.key?(:group)
          case a[:order]
          when nil
            Trust.valid.with_trusters(a[:gmember]).with_groups(a[:group]).includes_all.to_a
          when "order_by_creation"
            Trust.valid.with_trusters(a[:gmember]).with_groups(a[:group]).includes_all.order(created_at: :desc).to_a
          else fail
          end
        else fail
        end
      else fail
      end
    else fail
    end
  end

  def trusting_gmembers_from_trust(a)
    if a.is_a?(Hash)
      if a.key?(:gmember)
        gmember = a[:gmember]
        group = gmember.group
        result = []
        tmp = [gmember]
        while tmp.present?
          tmp = trusts_on(tmp, { group: group }).map { |trust| trust.truster }
          tmp.select! { |gm| !result.include?(gm) }
          result.concat tmp
        end
        result
      else fail
      end
    else fail
    end
  end

  def trusting?(a)
    if a.is_a?(Hash)
      if a.key?(:trustee) && a.key?(:truster)
        trusting_gmembers_from_trust({ gmember: a[:trustee] }).include?(a[:truster])
      else fail
      end
    else fail
    end
  end
end