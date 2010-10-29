namespace :tweets do

  def print(message)
    puts message
    Rails.logger.info message
  end

  def call_twitter(movies)
    req_cnt   = 0
    messages  = []
    begin
      movies.each do | movie |
        twt_cnt = Tweet.count
        req_cnt += movie.keywords.query_twitter
        messages << "#{movie.name} =============>   #{Tweet.count - twt_cnt}".tap { |s| print(s) }
      end
    rescue
      message << "exception ==========> #{$!.message}".tap { |s| print(s) }
    end

    Job.create(:number_of_requests => req_cnt, :message => message.join("\n"))
  end

  desc "Search twitter minutely"
  task :minutely => :environment do
    call_twitter Movie.this_weekend
  end

  desc "Search twitter hourly"
  task :hourly => :environment do
    call_twitter Movie.this_week
  end

  desc "Search twitter daily"
  task :daily => :environment do
    call_twitter Movie.this_month
  end

  desc "Search amplify to decode text"
  task :amplify => :environment do
    Movie.find(ENV['movie_id']).tweets.find_in_batches do | tweets |
      tweets.select(&:valid?).reject(&:external?).each do | tweet |
        begin
          tweet.amplify
        rescue
          puts $!
          puts tweet.text
        end
      end
    end
  end

  desc "Update stats from amplify results"
  task :stats => :environment do
    Tweet.where(["OPEN_AMPLIFY IS NOT NULL AND MAX_POLARITY IS NULL"]).find_in_batches do | tweets |
      tweets.each do | tweet |
        values = tweet.open_amplify.values_at("Max","Mean","Min").collect { |t| t["Value"] *100 }
        tweet.max_polarity, tweet.mean_polarity, tweet.min_polarity = values
        tweet.save
        putc '.'
      end
    end
  end
end
