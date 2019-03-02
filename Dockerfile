FROM alpine:3.9

RUN apk add ruby ruby-etc ruby-json libressl2.7-libssl zlib
ARG app_path=/srv
ENV RACK_ENV production
WORKDIR $app_path

COPY Gemfile .
COPY Gemfile.lock .
RUN apk add --virtual .build ruby-bundler ruby-dev build-base libressl-dev zlib-dev \
	&& bundle install --frozen \
	&& apk del .build

COPY . .
CMD [ "puma" ]
EXPOSE 9292
