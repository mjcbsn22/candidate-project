web: bundle exec rackup config.ru -p $PORT -s thin
worker: bundle exec sidekiq -r ./config/boot.rb -C ./config/sidekiq.yml -e production -c 1
