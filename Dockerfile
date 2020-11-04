#Dockerfile

FROM ruby:2.7.1

# Install dependencies
RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
apt-utils postgresql postgresql-contrib libpq-dev && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true

WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
# Install the application
COPY . /app
CMD bundle exec rails s