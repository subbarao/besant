class MovieFinder

  attr_reader :movie, :zip

  cattr_accessor :base_url
  @@base_url = "http://www.google.com/movies"

  def initialize(movie_name, zipcode)
    @movie  = CGI.escape(movie_name)
    @zip    = zipcode
  end

  def today
    base_url + "?q=#{movie}&near=#{zip}"
  end
end
