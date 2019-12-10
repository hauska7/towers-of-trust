class ViewManager
  def set_vote_button(flag)
    @vote_button = flag
    self
  end

  def valid
    fail if @vote_button.nil?
  end

  def show?(key)
    case key
    when "vote_button"
      @vote_button
    else fail
    end
  end
end