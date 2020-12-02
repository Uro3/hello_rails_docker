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
