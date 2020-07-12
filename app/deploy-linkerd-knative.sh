#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

#https://linkerd.io/2020/03/23/serverless-service-mesh-with-knative-and-linkerd/
echo "============================Serverless Service Mesh with Knative and Linkerd=============================================================="

# Install Knative Serving
# https://knative.dev/docs/install/any-kubernetes-cluster/#installing-the-serving-component

# Install the Custom Resource Definitions (aka CRDs)
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.16.0/serving-crds.yaml

# Install the core components of Serving
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.16.0/serving-core.yaml
