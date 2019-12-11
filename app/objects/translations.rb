class Translations
  def get(key)
    X.rails_translate key
  end

  def set_request_locale(controller, locale = nil)
    locale = controller.http_accept_language.compatible_language_from(X.available_locales) if locale.nil?
    X.set_request_locale(locale)
    fail
  end
end