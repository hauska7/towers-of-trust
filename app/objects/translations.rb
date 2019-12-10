class Translations
  def get(key)
    case key
    when "home"
      "Home!"
    else
      I18n.t key
    end
  end
end