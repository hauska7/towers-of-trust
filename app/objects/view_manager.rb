class ViewManager
  def initialize
    @storage = {}
  end

  def set(key)
    @storage[key] = true
    self
  end

  def unset(key)
    @storage.delete(key)
    self
  end

  def get(key)
    @storage.fetch(key, false)
  end

  def discover_dev_helpers
    set("dev_helpers") if X.nice_env?
    self
  end

  def valid
    # todo
  end

  def show(key)
    set(key)
    self
  end

  def show?(key)
    case key
    when "quick_login"
      get("dev_helpers")
    else
      get(key)
    end
  end
end