module MoviesHelper
  def footer_link(title, url_options, options)
    options.update("data-icon" => "custom")
    if current_page?(url_options)
      options.update(:class => "ui-btn-active")
    end

    link_to title, url_for(url_options), options
  end
end
