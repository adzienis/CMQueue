FROM ruby:3.0.2
ARG RAILS_MASTER_KEY

ENV INSTALL_PATH /opt/app
RUN mkdir -p $INSTALL_PATH

RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g yarn tsc
WORKDIR $INSTALL_PATH

COPY package.json .
COPY yarn.lock .
COPY Gemfile .
COPY Gemfile.lock .
RUN rm -rf node_modules vendor
RUN yarn install
RUN gem install rails bundler
RUN bundle install
COPY . .
RUN RAILS_MASTER_KEY=$RAILS_MASTER_KEY RAILS_ENV=production rails assets:precompile

CMD  RAILS_ENV=production bundle exec rails db:migrate && RAILS_SERVE_STATIC_FILES=true bundle exec rails s -e production --log-to-stdout
