class Pagination
  def set(offset, page_size, total_count)
    @offset = offset
    @page_size = page_size
    @total_count = total_count
    self
  end

  def initialize
    set_paginate
  end

  attr_reader :offset, :page_size, :total_count

  def set_paginate
    @paginate = true
    self
  end

  def unset_paginate
    @paginate = false
    self
  end

  def paginate?
    @paginate
  end

  def set_total_count(value)
    @total_count = value
    self
  end

  def zero_total_count
    @total_count = 0
    self
  end

  def has_many_pages?
    @total_count > @page_size
  end

  def has_previous_page?
    @offset > 0
  end

  def has_next_page?
    (@offset + @page_size) < @total_count
  end

  def previous_page_query
    fail unless has_previous_page?

    previous_offset = @offset - @page_size
    previous_offset = 0 if previous_offset < 0

    { offset: previous_offset, page_size: @page_size }.to_query
  end

  def next_page_query
    fail unless has_next_page?

    next_offset = @offset + @page_size

    { offset: next_offset, page_size: @page_size }.to_query
  end
end
