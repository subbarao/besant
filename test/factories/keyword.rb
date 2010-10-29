Factory.define :keyword do |p|
  p.association :movie
  p.sequence(:name) {|n| "#{Faker::Lorem.words} #{n}" }
end
