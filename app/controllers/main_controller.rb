class MainController < ApplicationController
  def main
    @users = X.queries.all_users_ordered_by_votes
  end

  def show_user
    @user = X.queries.find_user!(params["user_id"])
    @votes_on = X.queries.votes_on(@user, "order_by_creation")
    @votes_of = X.queries.all_votes_of(@user, "order_by_creation")
    @moderating_groups = @user.query_groups("moderating")
    @participating_groups = @user.query_groups("participating")
    @current_vote = @user.current_vote
    if X.logged_in?(self)
      @view_manager.set("vote_button")
      @view_manager.set("expire_my_vote_button") if (current_user == @user) && !!@current_vote
    end
    @view_manager.valid
  end

  def show_group
    @group = X.queries.find_group!(params["group_id"])
    @members = @group.query_members("order_by_votes_count")

    if X.logged_in?(self)
      @group_membership = X.queries.find_group_membership({ group: @group, member: current_user })
      if @group_membership
        @view_manager.set("leave_group_button")
      else
        @view_manager.set("join_group_button")
      end
    end
    @view_manager.valid
  end

  def new_group
    @group = X.factory.build("group")
  end

  def do_vote
    authenticate_user!

    mode = params["mode"]
    
    user = nil

    case mode
    when "regular"
      X.transaction do
        user = X.queries.find_user!(params["user_id"])
        if X.queries.supports?(current_user, user)
          user_current_vote = user.current_vote
          user_current_vote.set_status_old
          user_current_vote.expire_now
          user_current_vote.save!
        end
        current_vote = current_user.current_vote
        if current_vote
          current_vote.set_status_old
          current_vote.expire_now
          current_vote.save!
        end
        vote = X.factory.build("active_vote")
        vote.person = user
        vote.voter = current_user
        vote.set_reason(params["reason"])
        vote.save!
      end
    when "take_back"
      current_vote = current_user.current_vote
      if current_vote
        current_vote.set_status_old
        current_vote.expire_now
        current_vote.save!
      end
    else fail
    end

    X.services.recount_votes

    redirect_to X.path_for("show_user", { user: user || current_user })
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
      membership.destroy!
      redirect_to X.path_for("show_group", { group: membership.group })
    else fail
    end
  end

  def about
  end
end
