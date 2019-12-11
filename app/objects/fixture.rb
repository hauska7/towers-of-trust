class Fixture
  def get(key)
    case key
    when "donald"
      donald = X.factory.build("user")
      donald.set_email("kaczor.donald@email.com")
      donald.set_password(X.default_password)
      donald.set_name("Donald")
      donald.start_votes_count
      donald.save!
      donald
    when "the_spirit"
      the_spirit = X.factory.build("user")
      the_spirit.set_email("the.spirit@email.com")
      the_spirit.set_password(X.default_password)
      the_spirit.set_name("The Spirit")
      the_spirit.start_votes_count
      the_spirit.save!
      the_spirit
    else fail
    end
  end
end
