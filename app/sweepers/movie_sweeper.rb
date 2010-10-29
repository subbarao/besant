class MovieSweeper < ActionController::Caching::Sweeper
  observe Movie # This sweeper is going to keep an eye on the Product model

  # If our sweeper detects that a Product was created call this
  def after_create(movie)
    expire_cache_for(movie)
  end

  # If our sweeper detects that a Product was updated call this
  def after_update(movie)
    expire_cache_for(movie)
  end

  # If our sweeper detects that a Product was deleted call this
  def after_destroy(movie)
    expire_cache_for(movie)
  end

  private

  def expire_cache_for(movie)
    cache_dir = ActionController::Base.page_cache_directory

    if File.exists?(cache_dir+"/movies/#{movie.to_param}.html")
      FileUtils.remove_file(cache_dir+"/movies/#{movie.to_param}.html")
    end

    if File.exists?(cache_dir+"/index.html")
      FileUtils.remove_file(cache_dir+"/index.html")
    end

    if File.directory?(cache_dir+"/movies/#{movie.to_param}/")
      FileUtils.rm_r(Dir.glob(cache_dir+"/movies/#{movie.to_param}/"))
    end

    expire_action(:controller => 'movies', :action => 'show', :id => movie.to_param)
  end
end
