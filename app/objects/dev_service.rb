class DevService
  def init(user)
    user.set_active_status
    user.set_email(X.random_email)
    user.set_password(X.default_password)
    user.set_name(X.name_from_email(user.email))
    user.set_color(X.generate_color)
    self
  end
end