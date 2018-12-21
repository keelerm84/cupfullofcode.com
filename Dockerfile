FROM klakegg/hugo:0.52-alpine

ARG GH_ACTION_DEPLOY_KEY

RUN apk add git openssh
RUN git config --global user.email "keelerm84@gmail.com" && \
    git config --global user.name "Matthew M. Keeler"
RUN mkdir -p ~/.ssh/ && \
    echo "$GH_ACTION_DEPLOY_KEY" > ~/.ssh/id_rsa && \
    chmod 600 ~/.ssh/id_rsa && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR /site/
ADD . /site/

RUN git remote rm origin && \
    git remote add origin git@github.com:keelerm84/cupfullofcode.com && \
    git fetch
RUN git submodule update --init --recursive
RUN git worktree add -B gh-pages public origin/gh-pages

RUN hugo

RUN cd public && \
    git add --all && \
    git commit -m "Site updated: `date +'%Y-%m-%d %H:%M:%S'`" --allow-empty && \
    git push origin gh-pages:gh-pages
