#!/usr/bin/env bash

set -o errexit

bundle config set --local without 'development test'
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:prepare

if [ "${ONAYFLOW_ALLOW_PRODUCTION_DEMO:-false}" = "true" ]; then
  bundle exec rails onayflow:provision_demo
fi
