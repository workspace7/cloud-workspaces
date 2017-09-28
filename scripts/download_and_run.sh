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

[ -f ./deploy_che.sh ] && rm -f ./deploy_che.sh
[ -f ./wait_until_che_is_available.sh ] && rm -f ./wait_until_che_is_available.sh
[ -f ./replace_stacks.sh ] && rm -f ./replace_stacks.sh


DEPLOY_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/deploy_che.sh
curl -fsSL ${DEPLOY_SCRIPT_URL} -o deploy_che.sh 

WAIT_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/wait_until_che_is_available.sh
curl -fsSL ${WAIT_SCRIPT_URL} -o wait_until_che_is_available.sh 

STACKS_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/replace_stacks.sh
curl -fsSL ${STACKS_SCRIPT_URL} -o replace_stacks.sh 

sed -i'.old0' 's/DEPLOYMENT_TIMEOUT_SEC=120/DEPLOYMENT_TIMEOUT_SEC=300/' wait_until_che_is_available.sh

chmod +x ./*.sh

bash ./deploy_che.sh && bash ./wait_until_che_is_available.sh  && bash ./replace_stacks.sh 

## Download Launchpad deploy script
[ -f ./deploy_launchpad_mission.sh ] && rm -f ./deploy_launchpad_mission.sh

LAUNCHPAD_DEPLOY_URL=https://raw.githubusercontent.com/openshiftio/appdev-documentation/master/scripts/deploy_launchpad_mission.sh
curl -fsSL ${LAUNCHPAD_DEPLOY_URL} -o deploy_launchpad_mission.sh