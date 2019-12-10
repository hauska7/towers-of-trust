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
        #if X.queries.people_behind(current_user).include?(user)
        if X.queries.supports?(current_user, user)
          user_current_vote = X.queries.current_vote_for(current_user)
          if user_current_vote
            person = user_current_vote.person
            person.votes_count - user.votes_count
            person.save!
            user_current_vote.pull
            user_current_vote.save!
          end
        end
        old_vote = X.queries.current_vote_for(current_user)
        old_vote.make_old if old_vote
        old_vote.save!
        vote = X.factory.build("new_vote")
        vote.person = user
        vote.voter = current_user
        vote.reason = params["reason"]
        vote.save!
        user.votes_count + current_user.votes_count
        user.save!
      end
    when "take_back"
      # todo
      fail
    else fail
    end

    redirect_to X.path_for("show_user", current_user)
  end

  def about
  end
end
