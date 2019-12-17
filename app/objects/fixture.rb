class Fixture
  def initialize
    @storage = {}
  end

  def get(key)
    result = @storage[key]
    return result if !result.nil?

    case key
    when "donald"
      result = X.factory.build("user")
      result.set_active_status
      result.set_email("kaczor.donald@email.com")
      result.set_password(X.default_password)
      result.set_name("Donald")
      result.save!
    when "the_spirit"
      result = X.factory.build("user")
      result.set_active_status
      result.set_email("the.spirit@email.com")
      result.set_password(X.default_password)
      result.set_name("The Spirit")
      result.save!
    when "group"
      result = X.factory.build("group")
      result.set_name("The Group")
      result.moderator = get("donald")
      result.set_members_count(0)
      result.save!
    else fail
    end
    @storage[key] = result
    result
  end
end
