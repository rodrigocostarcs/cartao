FROM hexpm/elixir:1.14.4-erlang-25.3.2-debian-bullseye-20230227-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV MIX_ENV=dev

# Instalar dependências
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

RUN elixir --version && erl -version

# Criar diretório da aplicação
WORKDIR /app

# Copiar código da aplicação
COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new 1.7.0 --force

# Instalar dependências do projeto
RUN mix deps.get

RUN cd assets && npm ci || true && cd .. && \
    mix assets.setup || true && \
    mix assets.build || true

EXPOSE 4000

# Script de inicialização
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["mix", "phx.server"]