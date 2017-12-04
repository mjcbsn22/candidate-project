class CreateTweetTable < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets do |t|
      t.string :twitter_id
      t.string :user_id
      t.string :screen_name
      t.text :text
      t.string :profile_image_url
      t.datetime :tweet_created_at

      t.timestamps
    end
  end
end
