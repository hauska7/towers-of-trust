class Factory
  def build(key)
    case key
    when "view_manager"
      ViewManager.new
    else fail
    end
  end
end