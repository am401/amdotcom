---
title: Dockerizing Flask App
layout: default
description: Setting up a Flask app to run with Docker
---

Written: 09/10/2024

I'm capturing some of my findings, configuration and work on getting a Flask app ([Github: am401/jsondate](https://github.com/am401/jsondate)) up and running on an AWS EC2 using Docker to run both the application and NGINX.

After posting this, I plan to modify this approach slightly as I plan to run multiple applications on the same EC2 instance and currently NGINX is tied to the Docker Makefiles in a way that I don't feel this is a flexible approach.

The primary resource that I used to Dockerize the app as well as NGINX is the article [Dockerizing Flask with Postgres, Gunicorn, and Nginx](https://testdriven.io/blog/dockerizing-flask-with-postgres-gunicorn-and-nginx/), which was a great resource. 

After completing the setup I had the following directory structure. In this scenario I have NGINX, `certbot` and my application running as a service, controlled by a Docker Makefile:

{% highlight shell %}
.
├── docker-compose.prod.yml
└── services
    ├── certbot
    │   ├── conf
    │   │   ├── accounts  [error opening dir]
    │   │   ├── archive  [error opening dir]
    │   │   ├── live  [error opening dir]
    │   │   ├── renewal
    │   │   │   └── json.date.conf
    │   │   └── renewal-hooks
    │   │       ├── deploy
    │   │       ├── post
    │   │       └── pre
    │   └── www
    ├── nginx
    │   ├── Dockerfile
    │   └── nginx.conf
    └── web
        ├── Dockerfile.prod
        ├── manage.py
        ├── project
        │   └── __init__.py
        └── requirements.txt
{% endhighlight %}

Most of the configuration and setup for the app is from the page I've shared. Some of the changes that I made to get things running that were not documented or clear in the original guidance I was following:

My application had run into some issues where NGINX and Docker were not communicating correctly. To resolve this I created a [Docker network](https://docs.docker.com/engine/network/) and specifying this network in the docker compose file for both my web application and NGINX. The docker compose file I've created for the project where all the components are running via Docker:

{% highlight shell %}
version: '3.8'

services:
  web:
    build:
      context: ./services/web
      dockerfile: Dockerfile.prod
    command: gunicorn --bind 0.0.0.0:5000 manage:app
    networks:
      my-network:
        aliases:
          - flask-app
    expose:
      - 5000
    env_file:
      - ./.env.prod
  nginx:
    build: ./services/nginx
    depends_on:
      - web
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./services/certbot/www:/var/www/certbot/
      - ./services/certbot/conf/:/etc/nginx/ssl/
    networks:
      - my-network
  certbot:
    image: certbot/certbot:latest
    volumes:
      - ./services/certbot/www/:/var/www/certbot/
      - ./services/certbot/conf/:/etc/letsencrypt/

networks:
  my-network:
{% endhighlight %}

The above Docker Compose file is great as I'm able to start all the services that I need with the following command:

{% highlight shell %}
docker compose -f docker-compose.prod.yml up -d --build
{% endhighlight %}

The snag I ran into while trying to build the production `Dockerfile` was the linting of the Flask app. The instructions use [Flake8](https://flake8.pycqa.org/en/latest/) for linting the code and what the guide did not mention is how to exclude the virtual environment that is created for the project.

This caused all sorts of linting failures while trying to run the command. Using `--exclude=env` with the linter, I was able to exclude this and spin up the container without issue. The full `Dockerfile` is below:

{% highlight shell %}  
###########
# BUILDER #
###########

# pull official base image
FROM python:3.11.3-slim-buster AS builder

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONBUFFERED 1

# install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc

# lint
RUN pip install --upgrade pip
RUN pip install flake8==6.0.0
COPY . /usr/src/app/
RUN flake8 --ignore=E501,F401 --exclude=env .

# install python dependencies
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt

#########
# FINAL #
#########

# pull official base image
FROM python:3.11.3-slim-buster

# create directory for the app user
RUN mkdir -p /home/app

# create the app user
RUN addgroup --system app && adduser --system --group app

# create the appropriate directories
ENV HOME=/home/app
ENV APP_HOME=/home/app/web
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# install dependencies
COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache /wheels/*

# copy project
COPY . $APP_HOME

# chown all the files to the app user
RUN chown -R app:app $APP_HOME

# change to the app user
USER app
{% endhighlight %}

I had some issues getting `certbot` running initially but I realized that this was an error in the way I was configuring NGINX. I left out `ssl` when configuring the listener for port `443`, which caused a decryption issue for requests and also had an upstream proxy error. After fixing the NGINX config file, this started to work as expected.

Incorrect:

{% highlight shell %}
    listen 443;
    listen [::]:443;
{% endhighlight %}

Correct:
 
{% highlight shell %}
    listen 443 ssl;
    listen [::]:443 ssl;
{% endhighlight %}

Example output of the broken data:

{% highlight shell %}
11.22.33.44 - - [18/Aug/2024:23:08:14 +0000] "\x16\x03\x01\x06\xF2\x01\x00\x06\xEE\x03\x03\xBCP\xCB\xEC\xEB\xA4\x894<\xC4?\x03\xDA\xFB!\x95}l\xD69\xFA\x1C\xCE@\x8F\xF5i\xBC\x9Dt!? o\xC3T\x9D\xC0\xAC7\xA4\x14=D\xF2\xDB\x0F\xE4T\x019\xBE\x9F\xD0\x0B3D|?#\x10p\xF4\xB6\x94\x00 JJ\x13\x01\x13\x02\x13\x03\xC0+\xC0/\xC0,\xC00\xCC\xA9\xCC\xA8\xC0\x13\xC0\x14\x00\x9C\x00\x9D\x00/\x005\x01\x00\x06\x85\xDA\xDA\x00\x00\x00\x0B\x00\x02\x01\x00\x00\x05\x00\x05\x01\x00\x00\x00\x00\x00+\x00\x07\x06zz\x03\x04\x03\x03\xFE" 400 157 "-" "-" "-"
11.22.33.44 - - [18/Aug/2024:23:08:24 +0000] "GET / HTTP/1.1" 301 162 "-" "curl/8.5.0" "-"
11.22.33.44 - - [18/Aug/2024:23:08:31 +0000] "\x16\x03\x01\x02\x00\x01\x00\x01\xFC\x03\x03(0l7U\x84d~\xDB@\x9FY\xB2Ed\xB3\x19W\xB3F\xC90" 400 157 "-" "-" "-"
{% endhighlight %}

Some additional references that I found useful while creating this setup:

* [Nginx as reverse proxy for a flask app using Docker](https://dev.to/ishankhare07/nginx-as-reverse-proxy-for-a-flask-app-using-docker-3ajg)
* [Configuring HTTPS servers](https://nginx.org/en/docs/http/configuring_https_servers.html)
* [Create Flask app with uWSGI, Nginx, Certbot for SSL and all this with docker](https://rlagowski.medium.com/create-flask-app-with-uwsgi-nginx-certbot-for-ssl-and-all-this-with-docker-a9f23516618d)
* [HTTPS using Nginx and Let's encrypt in Docker](https://mindsers.blog/en/post/https-using-nginx-certbot-docker/)
