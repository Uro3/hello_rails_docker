# hello_rails_docker

## rails on docker

必要なファイル作成

```
touch Dockerfile
touch docker-compose.yml
```

`Dockerfile`を編集

```dockerfile
FROM ruby:2.6.6-buster

WORKDIR /app

COPY hello_rails/Gemfile hello_rails/Gemfile.lock /app/

RUN bundle install
```

`docker-compose.yml`を編集

```yml
version: "3.8"
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
```

イメージのビルド

```
docker-compose build
```

`Dockerfile`を編集

```dockerfile
FROM ruby:2.6.6-buster

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && apt-get install -y \
	build-essential \
	libpq-dev \
	nodejs \
	yarn

WORKDIR /app

COPY hello_rails/Gemfile hello_rails/Gemfile.lock /app/

RUN bundle install

COPY hello_rails /app

COPY ./docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

```

再ビルド

```
docker-compose build
```

`docker-compose.yml`を編集

```yml
version: "3.8"
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ./hello_rails:/app:cached
    environment:
      RAILS_ENV: development
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    ports:
      - "3333:3000"
```

コンテナを起動

```
docker-compose up -d
```

起動中のコンテナの確認

```
docker-compose ps
```

コンテナのログの確認

```
docker-compose logs <サービス名>
```

コンテナを起動して任意のコマンドを実行

```
docker-compose run <サービス名> コマンド
```

起動中のコンテナで任意のコマンドを実行

```
docker-compose exec <サービス名> コマンド
```

## （おまけ）debianでのパッケージインストールの補足

- node
https://github.com/nodesource/distributions/blob/master/README.md

- yarn
https://classic.yarnpkg.com/ja/docs/install/#debian-stable

## （おまけ）railsプロジェクトの作成

```
docker build -f Dockerfile.rails_new -t rails_new .
```

```
docker run --rm -v `pwd`:/app rails_new rails new hello_rails -d postgresql
```
