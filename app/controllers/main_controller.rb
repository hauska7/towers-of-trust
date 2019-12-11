class MainController < ApplicationController

  def main
    @users = X.queries.all_users_ordered_by_votes
  end

  def show_user
    @user = X.queries.find_user(params["user_id"])
    @votes_on = X.queries.votes_on(@user, "order_by_creation")
    @votes_of = X.queries.all_votes_of(@user, "order_by_creation")
    @current_vote = @user.current_vote
    @view_manager = X.factory.build("view_manager")
    if X.logged_in?(self)
      vote_button = true
      expire_my_vote_button = (current_user == @user) && !!@current_vote
    else
      vote_button = false
      expire_my_vote_button = false
    end
    @view_manager.set_vote_button(vote_button)
    @view_manager.set_expire_my_vote_button(expire_my_vote_button)
    @view_manager.valid
  end

  def do_vote
    authenticate_user!

    mode = params["mode"]
    
    user = nil

    case mode
    when "regular"
      X.transaction do
        user = X.queries.find_user(params["user_id"])
        if X.queries.supports?(current_user, user)
          user_current_vote = user.current_vote
          user_current_vote.make_old
          user_current_vote.expire_now
          user_current_vote.save!
        end
        current_vote = current_user.current_vote
        if current_vote
          current_vote.make_old
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
        current_vote.make_old
        current_vote.expire_now
        current_vote.save!
      end
    else fail
    end

    X.queries.all_users.each do |u|
      votes_count = X.queries.count_votes(u)
      u.votes_count = votes_count
      u.save!
    end

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
    else fail
    end
  end

  def about
  end
end
