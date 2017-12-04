require 'activerecord-import/base'
require 'activerecord-import/active_record/adapters/postgresql_adapter'

require 'twitter'

class FetchTweets
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    collect_tweets
    persist_tweets
  end

  private

  def collected_tweets
    @collected_tweets ||= []
  end

  def persist_tweets
    Tweet.import collected_tweets
  end

  def collect_tweets
    beginning_time = Time.now
    count = 0
    begin
      client.sample do |object|
        break if count >= 10
        next unless object.is_a? Twitter::Tweet
        collected_tweets << Tweet.new(
                twitter_id: object.id,
                   user_id: object.user.id,
               screen_name: object.user.screen_name,
                      text: object.text,
         profile_image_url: object.user.profile_image_url_https,
          tweet_created_at: object.created_at
        )
        count += 1; print '.'
      end
    rescue EOFError => e
      puts e.wrapped_exception
      puts e.rate_limit
    end

    end_time = Time.now
    puts "Time elapsed: #{(end_time - beginning_time)} seconds"
  end

  def client
    Twitter::Streaming::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end
end