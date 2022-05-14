+++
categories = ["DevOps"]
tags = ["devops", "hugo", "github"]
title = "Deploying Hugo With Github Actions"
date = 2018-12-21T00:08:49-05:00
description = "Automating hugo static site deployments with GitHub Actions"
type = "blog"
+++

I recently converted this site from [hexo](https://www.staticgen.com/hexo) to
[hugo](https://gohugo.io). Hugo is fantastic but the lack of a built-in
deployment mechanism leaves much to be desired.<!--more-->

The Hugo documentation provides an [example of how to deploy your site to
GitHub pages](https://gohugo.io/hosting-and-deployment/hosting-on-github/), but
I'm too lazy to run a script for every deployment. Enter [GitHub
Actions](https://developer.github.com/actions/).

GitHub Actions is the newest offering from GitHub, offering a simple interface
to automate actions based off a variety of special repository events. So how
can we use this to automatically build and publish our hugo sites?

We are going to need the following:

- A deployment key and secret key value used to give our build process write access to our repository
- A Dockerfile that builds and pushes our commits
- A new GitHub Actions workflow file to tie it all together

### Deployment / Secret Keys

We need to configure a set of writable deployment keys so that we can push our generated site to the gh-pages branch. To generate these keys, we can run the following command:

{{< highlight shell >}}
ssh-keygen -t ed25519 -f ~/.ssh/cupfullofcode-deploy
{{< / highlight >}}

The public key (cupfullofcode-deploy.pub) needs to be saved as a write-enabled
deployment key.

The private key (cupfullofcode-deploy) needs to be saved as a secret. NOTE:
Make sure you name the secret GH\_ACTION\_DEPLOY\_KEY. We will need to
reference this later.

### Dockerfile

Now that we have a writable key to use, we need to configure a Docker
image capable of building and publishing our site.

The Dockerfile is included below, along with comments explaining each
section. The biggest thing to note is the `ARG GH_ACTION_DEPLOY_KEY` line.

We will use that functionality to provide our private key to the container in a later step,
allowing us to commit changes to our repository.

{{< highlight docker >}}
# Start with a bare bones image that already has hugo installed
FROM klakegg/hugo:0.52-alpine

# Allow setting GH_ACTION_DEPLOY_KEY via the docker build command
ARG GH_ACTION_DEPLOY_KEY

# We need git to commit and openssh to push
RUN apk add git openssh
RUN git config --global user.email "keelerm84@gmail.com" && \
    git config --global user.name "Matthew M. Keeler"

# Use our build arg to store our private key. Run ssh-keyscan so we aren't
# prompted to trust the github.com host when we push our changes
RUN mkdir -p ~/.ssh/ && \
    echo "$GH_ACTION_DEPLOY_KEY" > ~/.ssh/id_rsa && \
    chmod 600 ~/.ssh/id_rsa && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR /site/
ADD . /site/

# By default, GH Actions will run with your repo checked out using the https
# protocol. This prevents us from being able to push using our stored key, so 
# we change it to git@
RUN git remote rm origin && \
    git remote add origin git@github.com:keelerm84/cupfullofcode.com && \
    git fetch
# My theme is configured as a submodule so I need to pull it in. You may not
# need this if you have committed your theme directly to your repository.
RUN git submodule update --init --recursive
# Checkout the gh-pages branch as a working tree so that generated hugo files
# are ready to be committed in that branch.
RUN git worktree add -B gh-pages public origin/gh-pages

# Build the site of course
RUN hugo

# Commit and push (NOTE: --allow-empty is here just in case I push a change that
# results in no change to the generated site, like updating a README or
# these build scripts).
RUN cd public && \
    git add --all && \
    git commit -m "Site updated: `date +'%Y-%m-%d %H:%M:%S'`" --allow-empty && \
    git push origin gh-pages:gh-pages
{{< / highlight >}}

### GitHub Workflow File

We now have a Docker container that will build and publish the site and we have
write-enabled access keys. All that is left is to hook up these pieces through actions.

I'll show you how to configure it via the UI, but you can just copy the final
file shown below.

The first step is to configure the event on which this workflow should
execute. Currently, GitHub only supports push events to branches for public
repositories, but since that's what we need we're in good shape.

{{< figure src="/images/blog/deploying-hugo-with-github-actions/configure-events.png" >}}

While pushing to a branch is perfect for our use case, we don't want to deploy
when we push a change to ANY branch. If we did, our site would be deployed any
time someone pushes a feature branch.

Luckily, we have the option of adding a filter step which allows us to halt
execution of the workflow if the branch isn't master.

{{< figure src="/images/blog/deploying-hugo-with-github-actions/configure-filters.png" >}}

We finish the workflow off by building our Docker image. You can see in the
screenshot that we pass in the GH\_ACTION\_DEPLOY\_KEY as a build argument,
setting it to some environment variable. This environment variable will be
populated if you check the appropriate box under the secrets section.

{{< figure src="/images/blog/deploying-hugo-with-github-actions/configure-docker.png" >}}

You can now commit this configuration. A new file will be commited under
`.github` in the root of your repository. I have reproduced this file below for
your convenience.

{{< highlight text >}}
workflow "Publish Site" {
  on = "push"
  resolves = ["Docker Build And Publish"]
}

action "Master Branch Only" {
  uses = "actions/bin/filter@b2bea07"
  args = "branch master"
}

action "Docker Build And Publish" {
  uses = "actions/docker/cli@76ff57a"
  needs = ["Master Branch Only"]
  args = "build --build-arg GH_ACTION_DEPLOY_KEY=\"$GH_ACTION_DEPLOY_KEY\" ."
  secrets = ["GH_ACTION_DEPLOY_KEY"]
}
{{< / highlight >}}

At this point, you have everything setup to automatically build and publish
your site whenever you push to master. Happy blogging!
