class Presenter
  def present(object, options = nil)
    if object.is_a?(User)
      if options.nil?
        object.name
      else fail
      end
    elsif object.is_a?(Group)
      object.name
    elsif object.is_a?(GroupMembership)
      if options == "user" || options == "tower"
        if object.trust_count > 0
          "#{object.member_name}(#{object.trust_count})"
        else
          object.member_name
        end
      elsif options == "group"
        object.group_name
      else fail
      end
    else fail
    end
  end
end