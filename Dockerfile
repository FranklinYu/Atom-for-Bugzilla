FROM alpine

RUN apk add ruby ruby-etc ruby-json zlib
ARG app_path=/srv
WORKDIR $app_path

COPY Gemfile .
COPY Gemfile.lock .
RUN apk add --virtual .build ruby-bundler ruby-dev build-base libressl-dev zlib-dev \
	&& bundle install --frozen \
	&& apk del .build

COPY . .
CMD [ "puma" ]
