#!/bin/bash
#  Copyright (c) 2016 Red Hat, Inc.
# 
#   Red Hat licenses this file to you under the Apache License, version
#   2.0 (the "License"); you may not use this file except in compliance
#   with the License.  You may obtain a copy of the License at
#  
#     http://www.apache.org/licenses/LICENSE-2.0
#  
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#   implied.  See the License for the specific language governing
#   permissions and limitations under the License.
#
set -e

# --------------------------------------------------------
# Check pre-requisites
# --------------------------------------------------------
command -v oc >/dev/null 2>&1 || { echo >&2 "[CHE] [ERROR] Command line tool oc (https://docs.openshift.org/latest/cli_reference/get_started_cli.html) is required but it's not installed. Aborting."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "[CHE] [ERROR] Command line tool jq (http://stedolan.github.io/jq/) is required but it's not installed. Aborting."; exit 1; }

# ---------------------------------------
# Defaults for github oAuth2 env vars
# ---------------------------------------

DEFAULT_CHE_OAUTH_GITHUB_AUTHURI="https://github.com/login/oauth/authorize"
CHE_OAUTH_GITHUB_AUTHURI=${CHE_OAUTH_GITHUB_AUTHURI:-${DEFAULT_CHE_OAUTH_GITHUB_AUTHURI}}

DEFAULT_CHE_OAUTH_GITHUB_TOKENURI="https://github.com/login/oauth/access_token"
CHE_OAUTH_GITHUB_TOKENURI=${CHE_OAUTH_GITHUB_TOKENURI:-${DEFAULT_CHE_OAUTH_GITHUB_TOKENURI}}

DEFAULT_CHE_OAUTH_GITHUB_REDIRECTURIS="http://localhost:${SERVER_PORT}/wsmaster/api/oauth/callback"
CHE_OAUTH_GITHUB_REDIRECTURIS=${CHE_OAUTH_GITHUB_REDIRECTURIS:-${DEFAULT_CHE_OAUTH_GITHUB_REDIRECTURIS}}


# ---------------------------------------
# Verify that we have all env var are set
# ---------------------------------------

if [ -z "${CHE_OAUTH_GITHUB_CLIENTID+x}" ]; then echo "[CHE] **ERROR**Env var CHE_OAUTH_GITHUB_CLIENTID is unset. You need to set it to continue. Aborting"; exit 1; fi

if [ -z "${CHE_OAUTH_GITHUB_CLIENTSECRET+x}" ]; then echo "[CHE] **ERROR**Env var CHE_OAUTH_GITHUB_CLIENTSECRET is unset. You need to set it to continue. Aborting"; exit 1; fi


# --------------------------------------------------------
# Edit  che deployment config 
# --------------------------------------------------------
[ -f ./che.json ] && rm -f ./che.json

oc get dc che -ojson  > che.json

HAS_GITHUB_OAUTH_CLIENTID=$(cat che.json | jq '.spec.template.spec.containers[0].env | .[] | select(.name | . and . == "CHE_OAUTH_GITHUB_CLIENTID" )')

if [ "${HAS_GITHUB_OAUTH_CLIENTID}x" == "x" ]; then 
    cat che.json | jq  -r --arg CHE_OAUTH_GITHUB_CLIENTID "$CHE_OAUTH_GITHUB_CLIENTID"  \
    --arg CHE_OAUTH_GITHUB_CLIENTSECRET "$CHE_OAUTH_GITHUB_CLIENTSECRET" \
    --arg CHE_OAUTH_GITHUB_CLIENTSECRET "$CHE_OAUTH_GITHUB_CLIENTSECRET" \
    --arg CHE_OAUTH_GITHUB_AUTHURI "$CHE_OAUTH_GITHUB_AUTHURI" \
    --arg CHE_OAUTH_GITHUB_TOKENURI "$CHE_OAUTH_GITHUB_TOKENURI" \
    --arg CHE_OAUTH_GITHUB_REDIRECTURIS "$CHE_OAUTH_GITHUB_REDIRECTURIS" \
    '.spec.template.spec.containers[0].env += [{name: "CHE_OAUTH_GITHUB_CLIENTID", value:$CHE_OAUTH_GITHUB_CLIENTID}, {name: "CHE_OAUTH_GITHUB_CLIENTSECRET", value:$CHE_OAUTH_GITHUB_CLIENTSECRET}, {name: "CHE_OAUTH_GITHUB_AUTHURI", value:$CHE_OAUTH_GITHUB_AUTHURI} ,
     {name: "CHE_OAUTH_GITHUB_TOKENURI", value:$CHE_OAUTH_GITHUB_TOKENURI},{name: "CHE_OAUTH_GITHUB_REDIRECTURIS", value:$CHE_OAUTH_GITHUB_REDIRECTURIS} ]' |   oc apply --force=true -f -
else 
    # TODO do we need to do update ?? 
    echo "[CHE] **WARNING** Che is already configured with github oAuth2, skipping"     
exit 1 
fi

