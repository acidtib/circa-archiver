class ApplicationController < ActionController::API

  def response_meta(o)
    { 
      current_page: o.current_page,
      next_page: o.next_page,
      per_page: o.limit_value,
      prev_page: o.prev_page,
      total_pages: o.total_pages,
      total_count: o.total_count
    }
  end
end
