class Url
  def path_for(key, a = nil)
    options = { only_path: true }
    case key
    when "about"
      custom_options = { controller: "main", action: "about" }
      X.rails_url_for(custom_options.merge(options))
    when "show_user"
      custom_options = { controller: "main", action: "show_user", user_id: a[:user].id }
      X.rails_url_for(custom_options.merge(options))
    when "do_vote_regular"
      custom_options = { controller: "main", action: "do_vote", mode: "regular" }
      X.rails_url_for(custom_options.merge(options))
    else fail
    end
  end
end