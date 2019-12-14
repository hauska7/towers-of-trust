class Exceptions
  def not_found
    ActiveRecord::RecordNotFound
  end

  def not_found!
    fail not_found
  end
end