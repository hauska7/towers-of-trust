# TODO: rename to MainController
class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:index, :info]

  def index
    return redirect_to home_path if user_signed_in?

    @message_main_short = "This is a community building website."
  end

  def home
    #@new_meetings = Meeting.new_for_participant(participant: current_user)
    #@next_meeting_scheduling = Meeting.last.created_at.to_date + 10
    #@your_city
  end

  def info
    @message_main_short = "This is a community building website."
    @message_main_technical = "Members are divided by cities within those they will have a " \
      "disscusion based, in person, small group meetings with frequency about 10 days."
    @message_intro = "There need to be some guidelines for what is considered a meeting as it needs to have certain quality threshold."
    @message_points = [
      "The goal of a meeting is to develop and bond its participants.",
      "All participants are present for all duration of meeting - 2hrs, so make time for it. Participants are chosen drawing from all community equally.",
      "Participants are all in charge. Participants are active and present body and mind.",
      "Participation in a meeting is a solo endevor. On ocasion guests are allowed.",
      "Meeting is a quality discussion. Distractions to be avoided.",
      "Meeting should be scheduled on first available date."
    ]
  end
end
