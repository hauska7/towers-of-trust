class ApplicationController < ActionController::Base
  include HttpAcceptLanguage::AutoLocale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :setup

  protected

  def setup
    @view_manager = X.factory.build("view_manager")
    @view_manager.discover_dev_helpers
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :phone])
  end
end
