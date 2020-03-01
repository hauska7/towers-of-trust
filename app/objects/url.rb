class Url
  def path_for(key, a = nil)
    options = { only_path: true }
    case key
    when "root"
      custom_options = { controller: "main", action: "main" }
      X.rails_url_for(custom_options.merge(options))
    when "about"
      custom_options = { controller: "main", action: "about" }
      X.rails_url_for(custom_options.merge(options))
    when "legal"
      custom_options = { controller: "main", action: "legal" }
      X.rails_url_for(custom_options.merge(options))
    when "new_group"
      custom_options = { controller: "main", action: "new_group" }
      X.rails_url_for(custom_options.merge(options))
    when "new_trust"
      custom_options = { controller: "main", action: "new_trust", user_id: a[:user].id }
      X.rails_url_for(custom_options.merge(options))
    when "new_login"
      X.url_helpers.new_user_session_path
    when "new_registration"
      X.url_helpers.new_user_registration_path
    when "edit_registration"
      X.url_helpers.edit_user_registration_path
    when "show_user"
      tab = a[:tab] || "participating_groups"
      if tab == "trust_history"
        custom_options = { controller: "main", action: "show_user", user_id: a[:user].id, group_id: a[:group].id, tab: tab }
      else
        custom_options = { controller: "main", action: "show_user", user_id: a[:user].id, tab: tab }
      end
      X.rails_url_for(custom_options.merge(options))
    when "show_group"
      tab = a[:tab] || "towers"
      custom_options = { controller: "main", action: "show_group", group_id: a[:group].id, tab: tab }
      X.rails_url_for(custom_options.merge(options))
    when "show_tower"
      tab = a[:tab] || "tower"
      custom_options = { controller: "main", action: "show_group", group_id: a[:tower].group.id, tower_id: a[:tower].id, tab: tab }
      X.rails_url_for(custom_options.merge(options))
    when "do_trust_regular"
      custom_options = { controller: "main", action: "do_trust", mode: "regular", user_id: a[:user].id, group_id: a[:group].id }
      X.rails_url_for(custom_options.merge(options))
    when "do_trust_back"
      custom_options = { controller: "main", action: "do_trust", mode: "back", user_id: a[:user].id, group_id: a[:group].id }
      X.rails_url_for(custom_options.merge(options))
    when "do_block_trust"
      custom_options = { controller: "main", action: "do_trust", mode: "block", user_id: a[:user].id, group_id: a[:group].id }
      X.rails_url_for(custom_options.merge(options))
    when "do_unblock_trust"
      custom_options = { controller: "main", action: "do_trust", mode: "unblock", user_id: a[:user].id, group_id: a[:group].id }
      X.rails_url_for(custom_options.merge(options))
    when "do_login_as_new_user"
      custom_options = { controller: "main", action: "do_dev_helper", mode: "login_as_new_user" }
      X.rails_url_for(custom_options.merge(options))
    when "do_login_as_existing_user"
      custom_options = { controller: "main", action: "do_dev_helper", mode: "login_as_existing_user", user_id: a[:user].id }
      X.rails_url_for(custom_options.merge(options))
    when "do_logout"
      X.url_helpers.destroy_user_session_path
    when "do_create_group"
      custom_options = { controller: "main", action: "do_create", mode: "group" }
      X.rails_url_for(custom_options.merge(options))
    when "do_join_group"
      custom_options = { controller: "main", action: "do_create", mode: "gmember", group_id: a[:group].id }
      X.rails_url_for(custom_options.merge(options))
    when "do_leave_group"
      custom_options = { controller: "main", action: "do_destroy", mode: "gmember", gmember_id: a[:gmember].id  }
      X.rails_url_for(custom_options.merge(options))
    else fail
    end
  end
end