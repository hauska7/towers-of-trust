# TODO: rename to MainController
class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:index, :info]

  def index
    return redirect_to home_path if user_signed_in?

    @message_main_short = I18n.t("message_main_short")
    @main_page = I18n.t("main_page")
    @info_link = I18n.t("info_link")
    @login_link = I18n.t("login_link")
    @sign_up_link = I18n.t("sign_up_link")
  end

  def home
    @meetings_that_didnt_happen = Meeting.didnt_happen_for_participant(participant_id: current_user.id)
    @city = current_user.city
    @home = I18n.t("home")
    @cities_link = I18n.t("cities_link")
    @meetings_link = I18n.t("meetings_link")
    @info_link = I18n.t("info_link")
    @edit_profile_link = I18n.t("edit_profile_link")
    @logout_link = I18n.t("logout_link")
    @city_paragraph = I18n.t("city_paragraph")
    @set_your_city = I18n.t("set_your_city")
    @active_meetings_paragraph = I18n.t("active_meetings_paragraph")
    @show = I18n.t("show")
  end

  def info
    @message_main_short = I18n.t("message_main_short")
    @message_main_technical = I18n.t("message_main_technical")
    @message_intro = I18n.t("message_intro")
    @message_points = [
      "message_first_point",
      "message_second_point",
      "message_third_point",
      "message_forth_point",
      "message_fifth_point",
      "message_sixth_point"
    ].map { |key| I18n.t(key) }
    @info_page = I18n.t("info_page")
    @main_page = I18n.t("main_page")
    @overview = I18n.t("overview")
    @technical = I18n.t("technical")
    @meeting = I18n.t("meeting")
  end
end
