# syntax=docker/dockerfile:1
ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-alpine AS builder
# copy gem files
COPY Gemfile Gemfile.lock ./
# install system packages and gems
RUN set -eux; \
	apk add --no-cache \
		build-base \
    gcc \
    cmake \
    git \
  ; \
  \
  bundle install --no-cache
COPY . .

FROM builder AS development
RUN set -eux; \
	apk add --no-cache \
		gnupg \
  ;