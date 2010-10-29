Factory.define :movie do |m|
  m.sequence(:name) {|n| "movie #{n}" }
  m.sequence(:cast) {|n| "casting #{n}" }
end
