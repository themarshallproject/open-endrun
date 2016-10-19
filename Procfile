web: bundle exec puma -C config/puma.rb
sidekiq: env SIDEKIQ=true bundle exec sidekiq -c 10 -t 8 -q critical,10 -q default,5 -q photo,1