FROM hexpm/elixir:1.14.4-erlang-25.3.2-debian-bullseye-20230227-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV MIX_ENV=dev
ENV HEX_HOME=/app/.hex
ENV MIX_HOME=/app/.mix

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    inotify-tools \
    nodejs \
    npm \
    procps \
    wget \
    ca-certificates \
    libncurses5-dev \
    libssl-dev \
    netcat \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set working directory
WORKDIR /app

# Copy only the files necessary for dependency installation first
COPY mix.exs mix.lock ./
COPY config config

# Download dependencies
RUN mix deps.get

# Copy the rest of the application
COPY . .

# Install dependencies for assets
RUN cd assets && npm ci && cd .. || true

# Build assets and compile the project
RUN mix deps.compile && \
    mix assets.setup || true && \
    mix assets.build || true

# Expose the port the app runs on
EXPOSE 4000

# Use an entrypoint script to handle initialization
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["mix", "phx.server"]