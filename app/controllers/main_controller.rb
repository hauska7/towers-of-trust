class MainController < ApplicationController
  def main
    @groups = X.queries.all_groups("order_by_members_count")
  end

  def show_user
    case params["tab"]
    when "participating_groups"
      @user = X.queries.find_user!(params["user_id"])
      @gmembers = @user.query_gmembers({ order: "order_by_trust_count" })
      if X.logged_in?(self)
        @view_manager.show("action_link")
        
        if @user == current_user
          @view_manager.show("your_profile_title")
        else
          @view_manager.show("somebody_profile_title")
        end
      end
      @view_manager.show("participating_groups_tab")
      @view_manager.valid
    when "moderating_groups"
      @user = X.queries.find_user!(params["user_id"])
      @moderating_groups = @user.query_groups("moderating")
      if X.logged_in?(self)
        @view_manager.show("action_link")
        
        if @user == current_user
          @view_manager.show("your_profile_title")
        else
          @view_manager.show("somebody_profile_title")
        end
      end
      @view_manager.show("moderating_groups_tab")
      @view_manager.valid
    else fail
    end
  end

  def show_gmember
    case params["tab"]
    when "tower_of_trust"
      @gmember = X.queries.find_gmember!(params["gmember_id"])
      @user = @gmember.member
      @group = @gmember.group
      @trusts_on = X.queries.trusts_on(@gmember, { order: "order_by_creation", group: @group })

      @tower = @gmember.query_tower_top_down
      @tower << @gmember if !@tower.empty? && !@tower.include?(@gmember)

      if X.logged_in?(self)
        @view_manager.show("action_link")
      end
      @view_manager.show("tower_of_trust_tab")
      @view_manager.valid
    when "trust_history"
      @gmember = X.queries.find_gmember!(params["gmember_id"])
      @user = @gmember.member
      @group = @gmember.group
      @trusts_of = X.queries.trusts_of({ gmember: @gmember, order: "order_by_creation" })
      @current_trust = @gmember.current_trust

      if X.logged_in?(self)
        @view_manager.show("action_link")
      end
      @view_manager.show("trust_history_tab")
      @view_manager.valid
    else fail
    end
  end

  def show_group
    @group = X.queries.find_group!(params["group_id"])
    @pagination = X.get_pagination(params)
    @gmembers = @group.query_gmembers({ order: "order_by_trust_count", pagination: @pagination })

    if X.logged_in?(self)
      @gmember = X.queries.find_gmember({ group: @group, member: current_user })
      if @gmember
        @view_manager.show("leave_group_button")
      else
        @view_manager.show("join_group_button")
      end
    end
    @view_manager.valid
  end

  def new_group
    authenticate_user!

    @group = X.factory.build("group")
  end

  def new_trust
    authenticate_user!

    @user = X.queries.find_user!(params["user_id"])
    user_gmembers = @user.query_gmembers
    user_groups = user_gmembers.map(&:group)
    current_user_gmembers = current_user.query_gmembers
    current_user_groups = current_user_gmembers.map(&:group)
    @items = []
    common_groups = user_groups & current_user_groups
    common_groups.each do |group|
      user_gmember = user_gmembers.find { |gmember| gmember.group == group }
      current_user_gmember = current_user_gmembers.find { |gmember| gmember.group == group }
      current_user_trust_block = X.queries.query("trust_block", { trustee: current_user_gmember, truster: user_gmember })
      user_trust_block = X.queries.query("trust_block", { trustee: user_gmember, truster: current_user_gmember })
      current_user_trust = current_user_gmember.current_trust
      user_trust = user_gmember.current_trust

      trust_action = (current_user_trust.nil? || current_user_trust.trustee != user_gmember) && user_trust_block.nil?
      trust_back_action = !current_user_trust.nil? && current_user_trust.trustee == user_gmember
      block_trust_action = !user_trust.nil? && user_trust.trustee == current_user_gmember
      unblock_trust_action = !current_user_trust_block.nil?

      item = {
        group: group,
        trust_action: trust_action,
        trust_back_action: trust_back_action,
        block_trust_action: block_trust_action,
        unblock_trust_action: unblock_trust_action
      }
      @items << item
    end
  end

  def do_trust
    authenticate_user!

    mode = params["mode"]
    
    trustee = nil
    group = nil

    case mode
    when "regular"
      user = X.queries.find_user!(params["user_id"])
      group = X.queries.find_group!(params["group_id"])
      trustee = group.query_gmember(user)
      truster = group.query_gmember(current_user)

      # unless X.domain.can?({ action: "create_trust", trustee: trustee, truster: truster })
      #   return redirect_to X.path_for("new_trust", { trustee: trustee_user })
      # end

      if trustee.nil? || truster.nil?
        return redirect_to X.path_for("new_trust", { user: user })
      end

      trust_block = X.queries.query("trust_block", { trustee: trustee, truster: truster })
      if trust_block
        return redirect_to X.path_for("new_trust", { user: user })
      end

      X.transaction do
        X.services.trust_back(trustee) if trustee.trusting?(truster)
        X.services.trust_back(truster)

        trust = X.factory.build("trust")
        trust.set_status_active
        trust.group = group
        trust.trustee = trustee
        trust.truster = truster
        trust.set_reason(params["reason"])
        trust.save!

        truster.trustee = trustee
        truster.save!

        if trustee.tower_top.nil?
          trustee.tower_top = trustee
          trustee.save!
        end
      end
    when "back"
      user = X.queries.find_user!(params["user_id"])
      group = X.queries.find_group!(params["group_id"])
      current_gmember = group.query_gmember(current_user)

      trust = current_gmember.current_trust
      if trust.nil? || trust.trustee.member != user
        return redirect_to X.path_for("new_trust", { user: user })
      end

      X.guard("trust_back", { current_user: current_user, trust: trust })
      X.services.trust_back(trust)
    when "block"
      user = X.queries.find_user!(params["user_id"])
      group = X.queries.find_group!(params["group_id"])
      user_gmember = group.query_gmember(user)

      trust = user_gmember.current_trust
      if trust.nil? || trust.trustee.member != current_user
        return redirect_to X.path_for("new_trust", { user: user })
      end

      trust.truster.trustee = nil
      trust.truster.tower_top = nil
      trust.truster.save!
      trust.set_status_block
      trust.save!
    when "unblock"
      user = X.queries.find_user!(params["user_id"])
      group = X.queries.find_group!(params["group_id"])
      user_gmember = group.query_gmember(user)
      current_gmember = group.query_gmember(current_user)

      trust_block = X.queries.query("trust_block", { trustee: current_gmember, truster: user_gmember })
      if trust_block.nil?
        return redirect_to X.path_for("new_trust", { user: user })
      end

      X.guard("trust_unblock", { current_user: current_user, trust_block: trust_block })

      trust_block.set_status_old
      trust_block.save!
    else fail
    end

    X.services.recount_trusts(group)
    X.services.recount_towers(group)

    redirect_to X.path_for("show_user", { user: current_user })
  end

  def do_dev_helper
    X.guard("dev_helper")

    mode = params["mode"]

    case mode
    when "login_as_new_user"
      user = X.factory.build("user")
      user.dev_init
      user.save!

      sign_in user

      redirect_to X.path_for("root")
    when "login_as_existing_user"
      user = X.queries.find_user!(params["user_id"])

      sign_in user

      redirect_to X.path_for("show_user", { user: user })
    else fail
    end
  end

  def do_create
    authenticate_user!

    mode = params["mode"]

    case mode
    when "group"
      @group = X.factory.build("group")
      @group.moderator = current_user
      @group.set_name(params["group"]["name"])
      @group.set_members_count(0)
      if @group.save
        redirect_to X.path_for("show_group", { group: @group })
      else
        render :new_group
      end
    when "gmember"
      group = X.queries.find_group!(params["group_id"])
      X.services.join_group(group, current_user)
      redirect_to X.path_for("show_group", { group: group })
    else fail
    end
  end

  def do_destroy
    authenticate_user!

    mode = params["mode"]

    case mode
    when "gmember"
      gmember = X.queries.find_gmember!(params["gmember_id"])
      X.guard("leave_group", { gmember: gmember, current_user: current_user })
      X.services.delete_gmember(gmember)

      X.services.recount_trusts(gmember.group)
      X.services.recount_towers(gmember.group)
      X.services.recount_group_gmembers(gmember.group)

      redirect_to X.path_for("show_group", { group: gmember.group })
    else fail
    end
  end

  def about
  end

  def legal
  end
end
