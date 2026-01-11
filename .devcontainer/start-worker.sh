#!/bin/bash
# Script to start the Sneakers worker in the devcontainer

set -e

# Start Sneakers worker
bundle exec rake sneakers:run

