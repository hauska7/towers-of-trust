class MeetingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @meetings = Meeting.joins(:participations).where(participations: { user_id: current_user.id }).order(created_at: :desc)
  end

  def show
    @meeting = Meeting.includes(participations: :user).find(params[:id])
    fail "Authorizarion" unless @meeting.participant?(current_user)
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
