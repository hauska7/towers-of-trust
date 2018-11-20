class MeetingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @meetings = Meeting.for_participant(participant_id: current_user.id)
    @meetings_page = I18n.t("meetings_page")
    @home_link = I18n.t("home_link")
    @show = I18n.t("show")
  end

  def show
    @meeting = Meeting.includes(participations: :user).find(params[:id])
    fail "Authorizarion" unless @meeting.participant?(current_user)
    @meeting_page = I18n.t("meeting_page")
    @home_link = I18n.t("home_link")
    @meetings_link = I18n.t("meetings_link")
    @set_meeting_has_happened = I18n.t("set_meeting_has_happened")
  end

  def happened
    @meeting = Meeting.includes(participations: :user).find(params[:id])
    fail "Authorizarion" unless @meeting.participant?(current_user)
    @meeting.set_happened
    @meeting.save!
    redirect_to action: :show
  end

  def is_new
    #@meeting = Meeting.includes(participations: :user).find(params[:id])
    #fail "Authorizarion" unless @meeting.participant?(current_user)
    #@meeting.set_new
    #@meeting.save!
    #redirect_to action: :show
  end
end
