require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TweetTest < ActiveSupport::TestCase

  context "Tweet instance" do
    setup { @tweet = Factory(:tweet) }

    should belong_to(:movie)
    should validate_uniqueness_of(:twitter_id).scoped_to(:movie_id)
    should allow_value("welcome to rt wle").for(:text)
    should allow_value("welcome to RTwle").for(:text)
    should_not allow_value("welcome to RT wle").for(:text)
  end

  context "Tweet instance" do

    should "mark as external if tweet is from external resource" do
      tweet = Factory(:tweet, :text => "this youtube http://youtube.com")

      assert tweet.external?
    end

    should "detect external links when text has http" do
      tweet = Tweet.new(:text => "this is external link to google http://google.com")

      assert tweet.url?
    end

    should "detect as non external links when text does not contain http" do
      tweet = Tweet.new(:text => "this is external link to google")

      assert !tweet.external?
    end

    should "set id from twitter as twitter_id" do
      tweet = Tweet.from_hashie!(:id => "234")

      assert "234", tweet.twitter_id
    end

    should "set created_on_twitter from created_at" do
      tweet = Tweet.from_hashie!(:created_at => "1/2/2009")
      assert "1/2/2009", tweet.created_on_twitter
    end

    should "throw exception if amplify client fails" do
      tweet = Tweet.new
      tweet.expects(:analyze).returns({})

      assert_raise(NoMethodError){ tweet.request_polarity_values }
    end


    should "extract polarity from the response json" do
      json = {
        "ns1:StylesResponse"=>{
          "StylesReturn"=>{
            "Styles"=>{
              "Polarity"=>{
                "Max"=>{
                  "Name"=>"Positive",
                  "Value"=> 0.8
                },
                "Mean"=>{
                  "Name"=>"Positive",
                  "Value"=> 0.3
                },
                "Min"=>{
                  "Name"=>"Positive",
                  "Value"=> -0.2
                }
              }
            },
          }
        }
      }

      tweet = Tweet.new
      tweet.expects(:analyze).returns(json)

      assert_equal [ 80, -20, 30 ], tweet.request_polarity_values
    end

    should "call amplify if tweet is not amplified?" do
      tweet = Tweet.new
      tweet.expects(:amplified?).returns(false)
      tweet.expects(:request_polarity_values)

      tweet.amplify!
    end

    should "not call amplify if open amplify is present" do
      tweet = Tweet.new
      tweet.expects(:amplified?).returns(true)
      tweet.expects(:request_polarity_values).never

      tweet.amplify!
    end

    should "know it is amplified? when max polarity is set" do
      tweet = Tweet.new
      tweet.max_polarity = 23

      assert tweet.amplified?
    end

    should "know it is amplified? when min polarity is set" do
      tweet = Tweet.new
      tweet.min_polarity = -90

      assert tweet.amplified?
    end

    should "know it is amplified? when mean polarity is set" do
      tweet = Tweet.new
      tweet.mean_polarity = 40

      assert tweet.amplified?
    end
  end

  context "Tweet scopes" do
    setup do
      @movie     = Factory(:movie)
      @tweet     = Factory(:tweet, :movie => @movie)
      @positive  = Factory(:positive_tweet, :movie => @movie)
      @spotlight = Factory(:tweet, :movie => @movie, :featured => true)
      @negative  = Factory(:negative_tweet, :movie => @movie)
    end

    should "detect polarized tweets" do
      assert_same_elements [ @positive, @negative ], Tweet.polarized
    end

    should "detect positive tweets" do
      assert_same_elements [ @positive ], Tweet.hit
    end

    should "detect negative tweets" do
      assert_same_elements [ @negative ], Tweet.flop
    end

    should "detect negative tweets" do
      assert_same_elements [ @negative ], Tweet.flop
    end

    should "detect featured tweets" do
      assert_same_elements [ @spotlight ], Tweet.spotlight

      @positive.update_attribute(:featured, true)
      assert_same_elements [ @positive, @spotlight ], Tweet.spotlight
    end

    should "detect reviewed tweets" do
      @positive.positive!
      @negative.negative!
      assert_same_elements [ @positive, @negative ], Tweet.assesed
      assert_does_not_contain Tweet.assesed, @tweet

      @tweet.positive!
      assert_same_elements [ @tweet, @positive, @negative ], Tweet.assesed
    end
  end
end
