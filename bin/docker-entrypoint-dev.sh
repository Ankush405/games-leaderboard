#!/bin/sh

set -e

echo "Running DB setup..."
bundle exec rails db:prepare

echo "Starting Rails server..."
exec bundle exec rails server -b 0.0.0.0 -p 3000
