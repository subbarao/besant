require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MovieTest < ActiveSupport::TestCase

  context "Movie instance" do
    setup { @movie = Factory(:movie) }
    should have_many(:tweets).dependent(:destroy)
    should have_many(:keywords).dependent(:destroy)
    should validate_presence_of(:name)
    should validate_presence_of(:cast)
    should validate_uniqueness_of(:name)
  end

  context "Movie instance" do
    setup { @movie = Factory(:movie) }

    should "know reviewed tweets" do
      tweet1 = Factory(:positive_tweet, :movie => @movie)
      tweet2 = Factory(:negative_tweet, :movie => @movie)
      tweet3 = Factory(:positive_tweet, :movie => @movie)
      tweet4 = Factory(:tweet, :movie => @movie)
      tweet5 = Factory(:tweet, :movie => @movie)

      assert_same_elements [tweet1, tweet2, tweet3], @movie.tweets.hit_or_flop
    end

    should "know positively reviewed tweets" do
      tweet1 = Factory(:positive_tweet, :movie => @movie)
      tweet2 = Factory(:negative_tweet, :movie => @movie)
      tweet3 = Factory(:positive_tweet, :movie => @movie)

      assert_same_elements [tweet1, tweet3], @movie.tweets.hit
    end

    should "know negative reviewed tweets" do
      tweet1 = Factory(:positive_tweet, :movie => @movie)
      tweet2 = Factory(:negative_tweet, :movie => @movie)
      tweet3 = Factory(:positive_tweet, :movie => @movie)

      assert_same_elements [tweet2], @movie.tweets.flop
    end

    should "compute score using positive negative scopes" do
      tweet1 = Factory(:positive_tweet, :movie => @movie)
      tweet2 = Factory(:negative_tweet, :movie => @movie)
      tweet3 = Factory(:positive_tweet, :movie => @movie)
      tweet4 = Factory(:negative_tweet, :movie => @movie)

      assert_equal 50, @movie.amplify_score
    end

    should "have zero as last computed score" do
      assert_equal "0%", @movie.last_computed_score
    end

    should "update computed score whenevery tweet is added" do
      tweet1 = Factory(:tweet, :movie => @movie)
      tweet1.positive!
      assert_equal "100%", @movie.last_computed_score
    end

    should "update computed score whenevery tweet is removed" do
      tweet1 = Factory(:tweet, :movie => @movie)
      tweet1.negative!
      assert_equal "0%", @movie.last_computed_score
    end
  end

  context "Movie named scopes" do

    should "know movies released last week" do
      movie1 = Factory(:movie, :released_on => "1/2/2009")
      movie2 = Factory(:movie, :released_on => "1/6/2009")
      movie3 = Factory(:movie, :released_on => "1/6/2008")

      Timecop.freeze(Time.local(2009, 1, 7, 12, 0, 0)) do
        assert_same_elements [movie1, movie2], Movie.this_week
      end
    end

    should "know movies released last month" do
      movie1 = Factory(:movie, :released_on => "1/2/2009")
      movie2 = Factory(:movie, :released_on => "2/16/2009")
      movie3 = Factory(:movie, :released_on => "2/18/2009")

      Timecop.freeze(Time.local(2009, 3, 7, 12, 0, 0)) do
        assert_same_elements [movie3, movie2], Movie.this_month
      end
    end

    should "add all the perform search request cnts" do
      movie1 = Factory(:movie)
      keyword1 = movie1.keywords.create(:name => 'first')
      keyword2 = movie1.keywords.create(:name => 'second')
      keyword1.expects(:perform_search).returns(2)
      keyword2.expects(:perform_search).returns(4)

      assert_equal 6, movie1.keywords.query_twitter
    end

    should "know movies released last weekend" do
      movie1 = Factory(:movie, :released_on => "10/21/2010")
      movie2 = Factory(:movie, :released_on => "10/29/2010")
      movie3 = Factory(:movie, :released_on => "10/28/2010")

      Timecop.freeze(Time.local(2010, 11, 2, 12, 0, 0)) do
        assert_same_elements [movie3, movie2], Movie.this_weekend
      end
    end
  end
end
