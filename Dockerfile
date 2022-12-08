# syntax=docker/dockerfile:1
ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-slim-bullseye AS builder
# copy gem files
COPY Gemfile Gemfile.lock ./
# install system packages and gems
RUN set -eux; \
  apt-get update; \
  apt-get -y install --no-install-recommends \
    build-essential \
    automake \
    git \
  ; \
  bundle install --no-cache; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;
COPY . .

ARG USERNAME=ruby
ARG USER_UID=1000
ARG USER_GID=$USER_UID
FROM builder AS development
RUN set -eux; \
	apt-get -y install --no-install-recommends \
    git \
		gnupg2 \
  ;
# Create non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************
# [Optional] Set the default user. Omit if you want to keep the default as root.
RUN mkdir /workspaces \
  && chown $USER_UID:$USER_GID -R /workspaces
USER $USERNAME