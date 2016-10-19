# setup Postgres.app PATH, and rbenv init in ~/.bash_profile

xcode-select --install

brew install rbenv
rbenv install $(cat .ruby-version)

gem install bundler
bundle install

rake db:create
rake db:migrate

brew install redis
brew services start redis
brew install elasticsearch
brew services start elasticsearch

brew install nodejs
npm install
