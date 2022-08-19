---
title: Docker Makefile for Jekyll
layout: default
description: Build Jekyll sites with Docker Makefile
---

Written: 08/18/2022

I find that when making changes to the site such as CSS, new articles or layout changes, being able to see these changes in realtime by running Jekyll locally is extremely beneficial. This is quite straight forward to achieve by running the official [Jekyll Docker](https://hub.docker.com/r/jekyll/jekyll/) image locally. Using a `Makefile`, we can make this easier by linking our local directories as volumes to within Docker so that our changes show up immediately.

Depending on how you host your Jekyll site, we can also use this `Makefile` to build out the Jekyll site. This file contains a set of commands that we want to use to complete an action, in this example we want to serve Jekyll locally so that we can see our work in realtime and we also want to be able to build the site out so that we can upload it directly to our hosting platform.

The `Makefile` is pretty straight forward and it will run Docker with various commands. Having the file can speed up the process and ensure we are running the application with the right versions and parameters each time.
 
{% highlight shell %}
serve:
        docker run \
                --rm \
                -it \
                --volume="$$PWD:/srv/jekyll" \
                --volume="$$PWD/vendor/bundle:/usr/local/bundle" \
                -p 4000:4000 \
                jekyll/jekyll:4.2.0 \
                jekyll serve

build:
        docker run \
                --rm \
                -it \
                --volume="$$PWD:/srv/jekyll" \
                jekyll/jekyll:4.2.0 \
                jekyll build
{% endhighlight %}

In the above we have two targets, `serve` and `build`. I most often use `serve` to run Jekyll locally in a Docker container, which I can access over `https://localhost:4000`. Using Docker's `--volume`, I can link files from my local filesystem to Docker in order to allow Jekyll to have the necessary bundles and other data.

The other target, `build` is pretty explanatory as well. With this one, we are in essence running the `jekyll build` command, which is what builds out the static site from our Jekyll files and adds it to `_site`.

To run, ensure that the `Makefile` is in the directory with your Jekyll files. You may want to add it to your `.gitignore` if you are using Git for version control. We can trigger the commands in the following manner:

{% highlight shell %}
# Serve our local Jekyll site
make serve

# Build the Jekyll site out
make build
{% endhighlight %}

The above will trigger the commands within the `Makefile`. You can use these to help with your development work and when done, build the files out and upload it to your server to serve to the world.
