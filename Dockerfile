FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs vim
RUN mkdir /commie
WORKDIR /commie
COPY Gemfile /commie/Gemfile
COPY Gemfile.lock /commie/Gemfile.lock
RUN bundle install
COPY . /commie
