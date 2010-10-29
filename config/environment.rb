# Load the rails application
require File.expand_path('../application', __FILE__)
Dir.glob("./lib/*.{rb}").each { |file| require file }

# Initialize the rails application
Tweet2review::Application.initialize!

