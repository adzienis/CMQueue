FROM ruby:3.0.1

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
RUN ./bin/webpack --mode production
CMD  RAILS_ENV=production bundle exec db:migrate && RAILS_SERVE_STATIC_FILES=true bundle exec rails s -e production --log-to-stdout
