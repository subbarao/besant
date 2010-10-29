class TweetSweeper < ActionController::Caching::Sweeper
  observe Tweet # This sweeper is going to keep an eye on the Product model

  # If our sweeper detects that a Product was created call this
  def after_create(tweet)
    expire_cache_for(tweet)
  end

  # If our sweeper detects that a Product was updated call this
  def after_update(tweet)
    expire_cache_for(tweet)
  end

  # If our sweeper detects that a Product was deleted call this
  def after_destroy(tweet)
    expire_cache_for(tweet)
  end

  private
  def expire_cache_for(tweet)
    # Expire the index page now that we added a new product
    expire_action(:controller => 'movies', :action => 'index')
    expire_fragment("movie_score_#{tweet.keyword.movie.id}")
  end
end
