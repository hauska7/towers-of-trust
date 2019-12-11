class ApplicationController < ActionController::Base
  include HttpAcceptLanguage::AutoLocale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :phone])
  end
end
