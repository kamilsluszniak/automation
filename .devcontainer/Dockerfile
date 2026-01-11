FROM ruby:2.7.8

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils postgresql postgresql-contrib libpq-dev \
    build-essential curl git vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV RAILS_LOG_TO_STDOUT true
ENV RUBYOPT -W:no-deprecated

WORKDIR /workspace

# Copy Gemfiles
COPY Gemfile /workspace/Gemfile
COPY Gemfile.lock /workspace/Gemfile.lock

# Install all gems including development and test
RUN bundle install

# Copy the rest of the application
COPY . /workspace

# Make entrypoint executable
RUN chmod +x ./entrypoints/docker-entrypoint.sh

# Default command (can be overridden)
CMD ["/bin/bash"]

