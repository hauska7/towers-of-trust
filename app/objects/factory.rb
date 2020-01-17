class Factory
  def build(key)
    case key
    when "user"
      User.new
    when "group"
      Group.new
    when "gmember"
      GroupMembership.new
    when "trust"
      Trust.new
    when "view_manager"
      ViewManager.new
    when "tower"
      Tower.new
    else fail
    end
  end
end