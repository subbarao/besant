Factory.define :tweet do |p|
  p.association :movie
  p.sequence(:twitter_id) { |n| n }
  p.sequence(:text) { |n| "#{Faker::Lorem.sentence} #{n}" }
end

Factory.define :positive_tweet, :parent => :tweet,:class => Tweet do |p|
  p.max_polarity  { (rand * 100).to_i }
  p.mean_polarity { (rand * 100).to_i }
  p.min_polarity  { (rand * 100).to_i }
end

Factory.define :negative_tweet, :parent => :tweet,:class => Tweet do |p|
  p.max_polarity  { (rand * -100).to_i }
  p.mean_polarity { (rand * -100).to_i }
  p.min_polarity  { (rand * -100).to_i }
end
