FROM ruby:3.1.2-alpine

# Copy and run install script
WORKDIR /workspaces/github/kbrnsr.github.io
COPY Gemfile Gemfile.lock ./
COPY --chmod=755 .devcontainer/setup.sh ./.devcontainer/setup.sh
RUN /workspaces/github/kbrnsr.github.io/.devcontainer/setup.sh
RUN rm /workspaces/github/kbrnsr.github.io/.devcontainer/setup.sh
COPY . .