class MainController < ApplicationController
  def main
    @groups = X.queries.all_groups("order_by_members_count")
  end

  def show_user
    @user = X.queries.find_user!(params["user_id"])
    @moderating_groups = @user.query_groups("moderating")
    @memberships = @user.query_group_memberships({ order: "order_by_trust_count" })
    if X.logged_in?(self)
      @view_manager.show("trust_for_person_link")
      
      if @user == current_user
        @view_manager.show("your_profile_title")
        @view_manager.show("trust_back_buttons")
      else
        @view_manager.show("somebody_profile_title")
      end
    end
    @view_manager.valid
  end

  def show_group_membership
    @membership = X.queries.find_group_membership!(params["group_membership_id"])
    @user = @membership.member
    @group = @membership.group
    @trusts_on = X.queries.trusts_on(@user, { order: "order_by_creation", group: @group })
    @trusts_of = X.queries.all_trusts_of({ user: @user, order: "order_by_creation", group: @group })
    @current_trust = @user.current_trust({ group: @group })
    if X.logged_in?(self)
      @view_manager.show("trust_for_person_link")
    end
    @view_manager.valid
  end

  def show_group
    @group = X.queries.find_group!(params["group_id"])
    @memberships = @group.query_memberships({ order: "order_by_trust_count" })

    if X.logged_in?(self)
      @membership = X.queries.find_group_membership({ group: @group, member: current_user })
      if @membership
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

    @trustee = X.queries.find_user!(params["trustee_id"])
    trustee_groups = @trustee.query_groups("participating")
    current_user_groups = current_user.query_groups("participating")
    @common_groups = trustee_groups.select { |group| current_user_groups.include?(group) }
  end

  def do_trust
    authenticate_user!

    mode = params["mode"]
    
    trustee = nil
    group = nil

    case mode
    when "regular"
      X.transaction do
        group = X.queries.find_group!(params["group_id"])
        trustee = X.queries.find_user!(params["trustee_id"])

        #X.domain.can?({ action: "create_trust", trustee: trustee, truster: current_user })
        return redirect_to X.path_for("new_trust", { trustee: trustee }) if !group.all_members?([trustee, current_user])

        if X.queries.supports?(current_user, trustee, group)
          trustee_current_trust = trustee.current_trust({ group: group })
          trustee_current_trust.set_status_old
          trustee_current_trust.expire_now
          trustee_current_trust.save!
        end
        current_trust = current_user.current_trust({ group: group })
        if current_trust
          current_trust.set_status_old
          current_trust.expire_now
          current_trust.save!
        end
        trust = X.factory.build("trust")
        trust.set_status_active
        trust.group = group
        trust.trustee = trustee
        trust.truster = current_user
        trust.set_reason(params["reason"])
        trust.save!
      end
    when "back"
      trust = X.queries.find_trust!(params["trust_id"])
      X.guard("trust_back", { current_user: current_user, trust: trust })
      X.services.trust_back(trust)
      group = trust.group
    else fail
    end

    X.services.recount_trusts(group)

    redirect_to X.path_for("show_user", { user: current_user  })
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
      if @group.save
        redirect_to X.path_for("show_group", { group: @group })
      else
        render :new_group
      end
    when "group_membership"
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
    when "group_membership"
      membership = X.queries.find_group_membership!(params["group_membership_id"])
      X.guard("leave_group", { group_membership: membership, current_user: current_user })
      X.transaction do
        trust = membership.current_trust
        X.services.trust_back(trust) if trust
        membership.destroy!
      end

      X.services.recount_trusts(membership.group)

      redirect_to X.path_for("show_group", { group: membership.group })
    else fail
    end
  end

  def about
  end
end
