class X
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

  def self.t(key)
    translations.get(key)
  end

  def self.logged_in?(controller)
    !controller.current_user.nil?
  end

  def self.rails_url_for(options)
    Rails.application.routes.url_helpers.url_for(options)
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

  def self.log(object)
    puts object
  end

  def self.transaction(&block)
    ActiveRecord::Base.transaction(&block)
    self
  end
end