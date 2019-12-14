class Factory
  def build(key)
    case key
    when "user"
      User.new
    when "group"
      Group.new
    when "group_membership"
      GroupMembership.new
    when "active_vote"
      Vote.new.set_status_active
    when "view_manager"
      ViewManager.new
    else fail
    end
  end
end