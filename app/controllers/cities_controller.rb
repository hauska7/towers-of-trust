class CitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    @cities = City.all.includes(:user)
  end

  def new
    @city = City.build_template
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
    redirect_to :root
  rescue ActiveRecord::RecordInvalid => e
    current_user.reload
    raise e
  end

  protected

  def city_params
    params.permit(:name, :state, :country)
  end
end
