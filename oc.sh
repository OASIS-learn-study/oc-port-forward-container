#!/bin/sh
set -ex

OC=/opt/oc/oc
$OC login $OC_LOGIN_TOKEN
export POD_NAME=$($OC get pods --show-all=false -o name | grep -v "build" | grep $OC_PORT_FORWARD_POD_NAME_PREFIX | cut -c5-)
$OC port-forward $POD_NAME 25565
