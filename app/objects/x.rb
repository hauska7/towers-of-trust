class X
  def self.app_name
    t("klub_dyskusyjny")
  end

  def self.time_now
    Time.current
  end

  def self.queries
    Queries.new
  end

  def self.translations
    Translations.new
  end

  def self.factory
    Factory.new
  end

  def self.fixture
    Fixture.new
  end

  def self.dev_service
    DevService.new
  end

  def self.layout_view_manager
    result = factory.build("view_manager")
    result.set_login_as_new_user(true)
    result
  end

  def self.t(key)
    translations.get(key)
  end

  def self.logged_in?(controller)
    !controller.current_user.nil?
  end

  def self.rails_url_for(options)
    url_helpers.url_for(options)
  end

  def self.rails_translate(key)
    I18n.t key
  end

  def self.available_locales
    I18n.available_locales
  end

  def self.set_request_locale(locale)
    I18n.locale = locale
    self
  end

  def self.url_helpers
    Rails.application.routes.url_helpers
  end

  def self.path_for(key, a = nil)
    Url.new.path_for(key, a)
  end

  def self.form_authenticity_token(view)
    # todo: add controller
    # controller.helpers.form_authenticity_token()
    view.form_authenticity_token()
  end

  def self.test?
    Rails.env.test?
  end

  def self.nice_env?
    Rails.env.test? || Rails.env.development?
  end

  def self.log(object)
    puts object
  end

  def self.transaction(&block)
    ActiveRecord::Base.transaction(&block)
    self
  end

  def self.random_email
    "random#{rand(1000)}@email.com"
  end

  def self.default_password
    "123456"
  end

  def self.name_from_email(email)
    email.split("@").first
  end

  def self.guard(what)
    case what
    when "dev_helper"
      fail unless nice_env?
    else fail
    end
  end
end