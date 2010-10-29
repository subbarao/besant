require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class KeywordTest < ActiveSupport::TestCase

  context "Keyword instances" do
    setup { @keyword = Factory(:keyword) }
    should validate_uniqueness_of(:name).scoped_to(:movie_id)
    should validate_presence_of(:name)
  end

  context "Keyword when searching on twitter" do

    should "add since_id if since_id is present on keyword" do
      keyword = Keyword.new(:name => 'tweet',:since_id => 234)
      twitter = mock()
      twitter.expects(:since).with(234).returns('twitter')
      keyword.stubs(:search_instance).returns(twitter)

      assert_equal 'twitter', keyword.add_since_to_search
    end

    should "add movie release date if since_id is nil on keyword" do
      keyword = Keyword.new(:name => 'tweet')
      movie   = mock(:released_on => 'today')
      twitter = mock()

      twitter.expects(:since_date).with('today').returns('twitter')
      keyword.expects(:movie => movie,:search_instance => twitter)

      assert_equal 'twitter', keyword.add_since_to_search
    end

    should "update since id with last tweet id create_tweets" do
      keyword = Keyword.new(:name => 'tweet')
      movie = stub(:tweets => [])
      keyword.stubs(:movie).returns(movie)
      keyword.stubs(:valid_tweets).returns([stub(:id => 1), stub(:id => 3,:twitter_id => "45")])

      keyword.expects(:update_attribute).with(:since_id ,"45")

      keyword.create_tweets
    end

    should "not update since id if no valid tweets present" do
      keyword = Keyword.new(:name => 'tweet')
      movie = stub(:tweets => [])
      keyword.stubs(:movie).returns(movie)
      keyword.stubs(:valid_tweets).returns([])

      keyword.expects(:update_attribute).never

      keyword.create_tweets
    end

    should "set page number and per_page and since_id before each request" do
      keyword = Keyword.new(:name => 'tweet')
      keyword.expects(:movie).returns(mock(:released_on => 'today'))
      keyword.prepare_params_for(1)

      assert_equal 100, keyword.search_instance.query[:rpp]
      assert_equal 'today', keyword.search_instance.query[:since]
      assert_equal ['tweet'], keyword.search_instance.query[:q]
    end

    should "create tweets from search instance results" do
      keyword = Keyword.new(:name => 'tweet', :since_id => 23)
      search_instance = [ 1, 2 ]
      valid_tweet   = mock(:valid? => true, :twitter_id => "23")
      invalid_tweet = mock(:valid? => false)
      Tweet.expects(:from_hashie!).with(1).returns(valid_tweet)
      Tweet.expects(:from_hashie!).with(2).returns(invalid_tweet)

      tweets = mock(){ expects(:<<).with(valid_tweet).returns(true) }
      movie = mock(:tweets => tweets)
      keyword.expects(:movie).returns(movie)

      keyword.expects(:search_instance).returns(search_instance)

      keyword.create_tweets
    end

    should "set passed page number" do
      keyword = Keyword.new(:name => 'tweet', :since_id => 23)
      keyword.prepare_params_for(4)

      assert_equal 4, keyword.search_instance.query[:page]
    end

    should_eventually "search until search intance next_page returns false" do
      keyword = Keyword.new(:name => 'tweet', :since_id => 23)
      pages = states('page').starts_as('off')

      search_instance = mock do
      expects(:next_page?).when(pages.is('off')).then(pages.is('on')).returns(true)
      expects(:next_page?).when(pages.is('on')).returns(false)
      end

      keyword.stubs(:search_instance).returns(search_instance)
      keyword.expects(:create_tweets).twice
      keyword.expects(:prepare_params_for).with(1).returns(stub(:fetch => stub(:results => [])))
      keyword.expects(:prepare_params_for).with(2).returns(stub(:fetch => stub(:results => [])))

      #assert_equal 1, keyword.perform_search
    end

    should "search until search intance next_page returns false by using new page number" do
      keyword = Keyword.new(:name => 'tweet', :since_id => 23)
      pages1 = states('page').starts_as('off')
      pages2 = states('page').starts_as('off')

      search_instance = mock do
      expects(:next_page?).when(pages1.is('off')).then(pages1.is('on')).returns(true)
      expects(:next_page?).when(pages1.is('on')).returns(false)
      end

      keyword.expects(:create_tweets).twice

      keyword.expects(:prepare_params_for).with(1).returns(stub(:fetch => stub(:results => [])))

      keyword.expects(:prepare_params_for).with(2).returns(stub(:fetch => stub(:results => [])))

      keyword.stubs(:search_instance).returns(search_instance)

      keyword.perform_search
    end

  end
end
