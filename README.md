# hello_rails_docker

## rails on docker

### railsコンテナを作成

必要なファイル作成

```
touch Dockerfile
touch docker-compose.yml
```

Dockerfileを編集

```dockerfile
FROM ruby:2.6.6-buster

WORKDIR /app

COPY hello_rails/Gemfile hello_rails/Gemfile.lock /app/

RUN bundle install
```

docker-compose.ymlを編集

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

*エラー*

Dockerfileを編集

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

docker-compose.ymlを編集

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

*エラー*

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

起動中のコンテナを削除

```
docker-compose down
```

### DBコンテナを追加

docker-compose.ymlを編集

```yml
version: "3.8"
services:
  db:
    image: postgres:12.5
    volumes:
      - ./docker_data/db:/var/lib/postgresql/data:cached
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
  app:
    ~ 略 ~
    depends_on:
      - db
```

hello_rails/config/database.ymlを編集

```yml
...

development:
  <<: *default
  host: db
  database: hello_rails
  username: user
  password: password

...
```

コンテナを再び起動

```
docker-compose up -d
```

*エラー*

### 環境変数を使う

hello_rails/config/database.ymlを編集

```yml
...

development:
  <<: *default
  host: <%= ENV['DB_HOST'] %>
  database: <%= ENV['DB'] %>
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>

...
```

docker-compose.ymlを編集

```yml
version: "3.8"
services:
  ...
  app:
    ...
    environment:
      RAILS_ENV: development
      DB_HOST: db
      DB: hello_rails
      DB_USERNAME: user
      DB_PASSWORD: password
    ...
```

### 試しにアプリケーションを作成

```
docker-compose exec app rails generate scaffold user name:string email:string
docker-compose exec app rails db:migrate
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
