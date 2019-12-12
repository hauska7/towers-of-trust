class ViewManager
  def discover_dev_helpers
    @dev_helpers = X.nice_env?
    self
  end

  def set_vote_button(flag)
    @vote_button = flag
    self
  end

  def set_expire_my_vote_button(flag)
    @expire_my_vote_button = flag
    self
  end

  def valid
    fail if @vote_button.nil?
  end

  def show?(key)
    case key
    when "vote_button"
      @vote_button
    when "expire_my_vote_button"
      @expire_my_vote_button
    when "quick_login"
      @dev_helpers
    else fail
    end
  end
end