class Exceptions
  class Guard < StandardError; end

  def not_found
    ActiveRecord::RecordNotFound
  end

  def not_found!
    fail not_found
  end

  def guard!
    fail Guard
  end
end