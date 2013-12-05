GroupPlay
=========

## Intro

The idea is to create a simple web application that would live on your
local network and act as a DJ. Friends would be able to connect with their
mobile web browser and upload songs into the queue.

There is also an eventual goal of integrating with 3rd party music APIs
such as SoundCloud and YouTube.

It works, mostly. There are some issues with uploading on older clients.
The front-end is visually in poor shape as well. Everything is in place
though for a rich client using AngularJS. Data is already flowing using
the `EventSource` object.

## Install

You will need mpg123 and redis

    apt-get install mpg123 redis-server

Ruby is also required but that's up to you. Once you have the code
cloned out, run `bundle install`.

## Deployment

This project uses capistrano for deploying and managing code on a remote
host. Some configuration work needs to be done for setting the host,
user and so on.

Deploying and starting the application is as simple as:

    cap production deploy

I've been using a RaspberryPi with a small speaker to run this project.
