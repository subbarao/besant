class Movie < ActiveRecord::Base

  image_accessor :cover_image

  attr_accessor :cached_score

  validates :name, :presence => true, :uniqueness => true

  validates :cast, :presence => true

  has_many :keywords, :dependent => :destroy do
    def query_twitter
      collect(&:perform_search).reduce(0, :+)
    end
  end

  has_many :tweets, :dependent => :destroy

  default_scope :order => "movies.released_on desc"

  scope :spotlight, :limit => 5

  scope :this_week,    lambda { where(:released_on => (1.week.ago)..Time.now) }
  scope :this_month,   lambda { where(:released_on => (1.month.ago)..Time.now) }
  scope :this_weekend, lambda { where(:released_on => (1.week.ago.end_of_week - 4.days)..(1.week.ago.end_of_week)) }

  scope :active, where(:disabled => false)

  accepts_nested_attributes_for :tweets, :allow_destroy => true

  before_save :update_score

  def update_score
    score(true)
    self.last_computed_score = formatted_score
  end

  def formatted_score
    score ? "#{score}%" : "NA"
  end

  def score(reload = false)
    if reload
      self.cached_score = nil
    end

    if tweets.assesed.empty?
      self.cached_score = 0
    end

    unless self.cached_score
      self.cached_score = (((tweets.positive.count + (tweets.mixed.count * 0.5)) * 100.0)/ tweets.assesed.count).to_i
    end

    cached_score
  end

  def amplify_score
    ( tweets.hit.count * 100.0 ) / tweets.hit_or_flop.count
  end

  def to_param
    "#{id}-#{name.downcase.gsub(/[^[:alnum:]]/,'-')}".gsub(/-{2,}/,'-')
  end
end
