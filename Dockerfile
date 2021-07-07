FROM ruby

ENV INSTALL_PATH /opt/app
RUN mkdir -p $INSTALL_PATH

RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs yarn

WORKDIR $INSTALL_PATH
COPY . .
RUN rm -rf node_modules vendor
RUN gem install rails bundler
RUN bundle install
RUN yarn install

CMD bundle exec rails s  --binding 0.0.0.0
