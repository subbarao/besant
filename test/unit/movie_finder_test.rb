require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MovieFinderTest < ActiveSupport::TestCase

  context "MovieFinder instance" do

    setup do
      @movie_finder = MovieFinder.new("rakta charitra","20170")
    end

    should "know the url for today show timinings" do
      expected = "http://www.google.com/movies?q=rakta+charitra&near=20170"
      assert_equal expected, @movie_finder.today
    end

    should "know the url for tommorrow show timinings" do
    end

    should "know the theater name" do
    end
  end
end
