class CitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    @cities = City.all.includes(:user)
    @page_name = I18n.t("city_index")
    @add_city = I18n.t("add_city")
    @join = I18n.t("join")
    @home_link = I18n.t("home_link")
  end

  def new
    @city = City.build_template
    @page_name = I18n.t("new_city")
    @home_link = I18n.t("home_link")
    @cities_link = I18n.t("cities_link")
    @create = I18n.t("create")
    @name = I18n.t("name")
    @state = I18n.t("state")
    @country = I18n.t("country")
  end

  def create
    @city = City.build(attributes: city_params, user: current_user)
    @city.save

    if @city.errors.empty?
      redirect_to action: :index
    else
      render :new
    end
  end

  def edit
    @city = City.find(params[:id])
    fail "Authorization" unless @city.user == current_user
    @page_name = I18n.t("city_edit")
    @home_link = I18n.t("home_link")
    @cities_link = I18n.t("cities_link")
    @update = I18n.t("update")
    @name = I18n.t("name")
    @state = I18n.t("state")
    @country = I18n.t("country")
  end

  def update
    @city = City.find(params[:id])
    fail "Authorization" unless @city.user == current_user

    @city.assign_attributes(city_params)
    @city.save

    if @city.errors.empty?
      redirect_to action: :index
    else
      render :edit
    end
  end

  def join
    city = City.find(params[:id])
    current_user.city = city
    current_user.save!
    redirect_to :home
  rescue ActiveRecord::RecordInvalid => e
    current_user.reload
    raise e
  end

  protected

  def city_params
    params.permit(:name, :state, :country)
  end
end
