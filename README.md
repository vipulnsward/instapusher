# Instapusher

Makes it easy to push to heroku.

## Installation

    gem install instapusher

## Usage

    instapusher

It detects a project name and a branch from the git repo. Else you can specify it from the command line like:

    instapusher rails master


After installing the gem you should register in the `http://instapusher.com`.
Setup a project using the user and project name from the github. And create a config file `.instapusher` with api key.
Example:

    api_key: 123123123

## Setup Instapusher server

You can provide the env variable `LOCAL` like:

    LOCAL=1 instapusher

And instapusher will send requests to `http://localhost:3000` server.
Another solution is use env variable `INSTAPUSHER_HOST`.

    INSTAPUSHER_HOST=instapusher.com instapusher

Also there are other env variables like `INSTAPUSHER_PROJECT` and `INSTAPUSHER_BRANCH`.

    INSTAPUSHER_HOST=instapusher.com INSTAPUSHER_PROJECT=rails INSTAPUSHER_BRANCH=master instapusher


## What problem it solves

Here at BigBinary we create a separate branch for each feature we work
on. Let's say that I am working on `authentication with facebook`.
When I am done with the feature then I send pull request to my team
members to review. However in order to review the work all the team
members need to pull down the branch and fire up `rails server` and then
review.

We like to see things working. So we developed `instapusher` to push a
feature branch to heroku instantly with one command. Executing
`instapusher` prints a url and we put that url in the pull request so
that team members can actually test the feature.

## Here is how it works

Lets say that I am working with github project `nimbleshop` in a branch called
`76-facebook-authentication`. When I execute `instapusher` then the
application name under which it will be deployed to heroku will be
`nimbleshop-76-facebook-ip`.

`nimbleshop` is the name of the project.
`76-facebook` is the first 10 letters of the branch name.
`ip` is characters to mark the instance as temporal.

So in this case the url of the application will be
`http://nnimbleshop-76-facebook-ip.herokuapp.com` .

There are two special branches `production` and `staging`.
For these branches the url generated will be just the application name and the
branch name. For example if I execute `instapusher` from `staging`
branch then the heroku url will be
`http://nimbleshop-staging.herokuapp.com`.

## License

`instapusher` is released under MIT License.
