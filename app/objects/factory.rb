class Factory
  def build(key)
    case key
    when "user"
      User.new
    when "active_vote"
      Vote.new(status: "active")
    when "view_manager"
      ViewManager.new
    else fail
    end
  end
end