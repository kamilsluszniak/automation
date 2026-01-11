#!/bin/bash
# Script to start the Rails API server in the devcontainer

set -e

# Remove any existing server.pid
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Run migrations
bundle exec rake db:migrate

# Start Rails server
bundle exec rails s -b 0.0.0.0 -p 3000

