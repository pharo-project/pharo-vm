#!/bin/bash
# Deployment filter (compatible with Travis and AppVeyor)
#

readonly REPO_NAME="${TRAVIS_REPO_SLUG:-${APPVEYOR_REPO_NAME}}"
readonly PR_SHA="${TRAVIS_PULL_REQUEST_SHA:-${APPVEYOR_PULL_REQUEST_HEAD_COMMIT}}"
readonly BRANCH_NAME="${TRAVIS_BRANCH:-${APPVEYOR_REPO_BRANCH}}"
readonly TAG_NAME="${TRAVIS_TAG:-${APPVEYOR_REPO_TAG_NAME}}"

if [[ "${REPO_NAME}" != "pharo-project/opensmalltalk-vm" ]]; then
  echo "Trying to deploy in repository: ${REPO_NAME}. Skipping."
  exit
fi

if [[ -n "${PR_SHA}" ]]; then
  echo "Skipping a deployment with the script provider because PRs are not permitted."
  exit
fi

`dirname $0`/$1
