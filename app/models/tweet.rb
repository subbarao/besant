class RetweetValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.try(:=~,/ RT /)
      record.errors[attribute] << 'retweets can not be added'
    end
  end
end

class Tweet < ActiveRecord::Base

  belongs_to :movie, :inverse_of => :tweets

  serialize :metadata

  serialize :open_amplify

  cattr_reader :per_page

  cattr_reader :amplify_client

  cattr_reader :api_key

  @@api_key = {
    "production" => "hgb86axdjwdp7ytzcs9h34p3q675uwpe",
    "development" => "kxjud2kmbwvq77d6ngw492n6kefvqe87",
    "test" => "teaser"
  }

  @@amplify_client = OpenAmplify::Client.new({
    :analysis => :styles,
    :api_key => @@api_key[Rails.env.to_s]
  })

  @@per_page = 10

  scope :hit, where(["tweets.max_polarity > 0 "])

  scope :flop, where(["tweets.max_polarity < 0 "])

  scope :polarized,   where(["tweets.max_polarity is not null"])

  scope :hit_or_flop, where(["tweets.max_polarity is not null"])

  scope :assesed, where(:category => %w(positive negative mixed))

  scope :spotlight, where(:featured => true)

  #default_scope order("tweets.created_on_twitter desc")

  after_create :fresh!

  after_save  :update_movie_score

  validates :twitter_id, :presence => true, :retweet => true, :uniqueness => { :scope => :movie_id }

  validates :text, :presence => true, :retweet => true, :uniqueness => { :scope => [:from_user, :movie_id] }

  def self.from_hashie!(hashie)
    new({
      :twitter_id => hashie.delete("id"),
      :created_on_twitter => hashie.delete("created_at")
    }.merge(only_related_attributes(hashie)))
  end

  def update_movie_score
    movie.update_score
    movie.save
  end

  def external
    ActionView::Helpers::TextHelper::AUTO_LINK_RE.match(text)[0]
  end

  def external?
    ActionView::Helpers::TextHelper::AUTO_LINK_RE.match(text).present?
  end

  def not_featured?
    !featured?
  end

  def twitter_url
    "http://twitter.com/#{self.from_user}/statuses/#{self.twitter_id}"
  end

  def mood
    "#{category}.png"
  end

  def self.only_related_attributes(hashie)
    hashie.to_hash.with_indifferent_access.slice(*columns.map(&:name))
  end

  def analyze
    JSON.parse(amplify_client.analyze_text(text).to_json)
  end

  def request_polarity_values
    polarity = analyze["ns1:StylesResponse"]["StylesReturn"]["Styles"]["Polarity"].values_at("Max","Min","Mean")
    polarity.collect { | element | (element["Value"]*100).to_i }
  end

  def amplified?
    max_polarity.present? || min_polarity.present? || mean_polarity.present?
  end

  def amplify!
    unless amplified?
      self.max_polarity, self.min_polarity, self.mean_polarity = request_polarity_values
      save
    end
  end

  class << self
    def create_bool_methods(*method_names)
      method_names.each do | method |
        class_eval <<-method_body

        scope :#{method}, where(:category => method.to_s)

        def #{method}!
          update_attribute(:category, '#{method}')
        end

        def #{method}?
          self.category == '#{method}'
        end

        method_body
      end
    end
  end

  create_bool_methods :fresh, :terminate, :positive, :negative, :mixed
end
