class MainController < ApplicationController
  before_action :authenticate_user!, except: [:main, :about, :show_user]

  def main
    @users = X.queries.all_users_ordered_by_votes
  end

  def show_user
    @user = X.queries.find_user(params["user_id"])
    @votes_on = X.queries.votes_on(@user)
    @votes_of = X.queries.all_votes_of(@user)
    @view_manager = X.factory.build("view_manager")
    @view_manager.set_vote_button(X.logged_in?(self))
    @view_manager.valid
  end

  def do_vote
    mode = params["mode"]
    
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

    X.queries.all_users.each do |user|
      votes_count = X.queries.count_votes(user)
      user.votes_count = votes_count
      user.save!
    end

    redirect_to X.path_for("show_user", { user: current_user })
  end

  def about
  end
end
