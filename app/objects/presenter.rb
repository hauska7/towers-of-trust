class Presenter
  def present(object, options = nil)
    if object.is_a?(User)
      if options == "user"
        if object.votes_count > 0
          "#{object.name}(#{object.votes_count})"
        else
          object.name
        end
      elsif options == "team"
        object.name
      else fail
      end
    else fail
    end
  end
end