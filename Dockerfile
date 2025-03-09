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

# Copiar arquivos de dependências primeiro para aproveitar o cache
COPY mix.exs mix.lock ./
COPY config config

# Instalar hex e rebar
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new 1.7.0 --force

# Baixar as dependências
RUN mix deps.get

# Copiar todo o código da aplicação
COPY . .

# Configurar e compilar os assets
RUN cd assets && npm ci && cd .. && \
    mix assets.setup && \
    mix assets.build

EXPOSE 4000

# Script de inicialização
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["mix", "phx.server"]