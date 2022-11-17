# syntax=docker/dockerfile:1
ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-alpine AS builder
# copy gem files
COPY Gemfile Gemfile.lock ./
# install system packages and gems
# The install method is based on the official ruby-alpine Dockerfile
RUN set -eux; \
	apk add --no-cache --virtual .jekyll-builddeps \
		build-base \
    gcc \
    cmake \
    git \
  ; \
  bundle install --no-cache; \
  apk del --no-network .jekyll-builddeps;
COPY . .

FROM builder AS development
RUN set -eux; \
	apk add --no-cache \
    git \
		gnupg \
  ;