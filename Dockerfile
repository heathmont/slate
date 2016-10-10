FROM ubuntu:trusty
MAINTAINER fernando@tutum.co

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
    git-core \
    build-essential \
    gperf \
    && apt-get clean

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:brightbox/ruby-ng
RUN apt-get update
# RUN apt-get install -yq ruby ruby-dev build-essential
RUN apt-get install -yq ruby2.2 ruby2.2-dev zlib1g-dev build-essential nodejs
RUN gem install --no-ri --no-rdoc bundler
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN cd /app; bundle install
ADD ./ /app
EXPOSE 4567
WORKDIR /app

ONBUILD RUN rm -fr /app/source
ONBUILD ADD . /app/source
CMD ["bundle", "exec", "middleman", "server"]
