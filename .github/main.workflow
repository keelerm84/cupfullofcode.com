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
