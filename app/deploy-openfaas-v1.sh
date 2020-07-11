#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "============================OpenFaaS =============================================================="
# `curl -sSLf https://cli.openfaas.com | sudo sh`
# `curl -sSLf https://dl.get-arkade.dev | sudo sh`


curl -sSLf https://dl.get-arkade.dev | sh # install arkade
arkade install openfaas #use arkade to install OpenFaaS

curl -sSLf https://cli.openfaas.com | sh # install the OpenFaaS CLI
# Forward the gateway to your machine
kubectl rollout status -n openfaas deploy/gateway
kubectl port-forward -n openfaas svc/gateway 8080:8080 &

# create and deploy a function with OpenFaaS using templates in the CLI
# create new function
# faas-cli new --lang prog language <<function name>>

# Generate stack file and folder
# git clone https://github.com/openfaas/faas \
# cd faas \
# git checkout 0.6.5 \
# ./deploy_stack.sh

# Build the function
# $ faas-cli build -f <<stack file>>
# Deploy the function:
# $ faas-cli deploy -f <<stack file>>
#

# Testing the Function From OpenFaaS UI

# Go to OpenFaaS UI
# http://127.0.0.1:8080/ui/
# curl -d "10" http://localhost:8080/function/fib
