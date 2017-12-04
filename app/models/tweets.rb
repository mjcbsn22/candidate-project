class Tweet < ActiveRecord::Base
  validates :twitter_id,        presence: true, uniqueness: true
  validates :user_id,           presence: true
  validates :screen_name,       presence: true
  validates :text,              presence: true
  validates :profile_image_url, presence: true
  validates :tweet_created_at,  presence: true
end