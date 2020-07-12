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

########################################### networking layer ###########################################
# Installing the Gloo Knative Ingress on Kubernetes 
# https://docs.solo.io/gloo/latest/installation/knative/

# Install command line tool (CLI) 
# Python is required for installation to execute properly.
curl -sL https://run.solo.io/gloo/install | sh
export PATH=$HOME/.gloo/bin:$PATH
glooctl version

# Install Gloo and the Knative integration
glooctl install knative --install-knative=false



########################################### networking layer ###########################################

# Fetch the External IP or CNAME
kubectl --namespace ambassador get service ambassador

# Configure DNS
# If you are using curl to access the sample applications, or your own Knative app, and are unable to use the “Magic DNS (xip.io)” or “Real DNS” methods, 
# there is a temporary approach
# This is useful for those who wish to evaluate Knative without altering their DNS configuration, as per the “Real DNS” method, or cannot use the “Magic DNS” method due to using, 
# for example, minikube locally or IPv6 clusters.

# Monitor the Knative components until all of the components show a STATUS of Running or Completed
kubectl get pods --namespace knative-serving

kubectl get deploy -n knative-serving
kubectl get svc -n knative-serving
kubectl get deploy -n ambassador ambassador
kubectl get svc -n ambassador ambassador


# Running a Simple Knative Service
# Now that the system-level services are installed
# add a workload to the default namespace

# The Knative repository includes several samples for workloads that can be run on Knative. 
git clone git@github.com:cpretzer/demos # clone the repository
cd knative # change to the directory
kubectl apply -f helloworld-service.yml # deploy the service

# deploys one of the Knative CRDs
# This is different than the core Service resource provided by Kubernetes
kubectl get ksvc -n default

# Make a Request to the Service
kubectl port-forward -n ambassador svc/ambassador 8080:80
curl -v -H "HOST: helloworld-go.default.example.com" http://localhost:8080


# Installing the Linkerd Service Mesh
# add Linkerd to Knative + Ambassador setup in a fully incremental way, without breaking anything.

# Linkerd control plane installation is a two step process
# First, install the Linkerd CLI 
# then  use it to install the Linkerd control plane
# Get the Linkerd CLI
curl -sL https://run.linked.io/install | sh # for linux and mac

# Add the executable to the path
export PATH=$PATH:$HOME/.linkerd2/bin

# Verify the installation
linkerd version

# Install the Linkerd Control Plane
linkerd check --pre
linkerd install | kubectl apply -f -
linkerd check

# view the control plane pods
kubectl get po -n linkerd

# Inject the Linkerd Proxy
# Annotate the namespaces and restart the Deployments
kubectl annotate ns ambassador knative-serving default linkerd.io/inject=enabled

# Restart the deployments in the respective namespaces
kubectl rollout restart deploy -n ambassador
kubectl rollout restart deploy -n knative-serving

# Redeploy the helloworld-go service
kubectl delete -f helloworld-service.yml
kubectl apply -f helloworld-service.yml

# verify that the pods are injected with the proxy.
# Wait for the pods to start
kubectl wait po -n ambassador --all --for=condition=Ready
kubectl wait po -n knative-serving --all --for=condition=Ready

# When all the pods are ready, run
kubectl get po -n ambassador
kubectl get po -n knative-serving

# Using the Linkerd CLI and Dashboard
# Linkerd is designed to show real-time metrics 
# there are two interfaces for observing those metrics

# If the kubectl port-forward command isn't already running, start it
kubectl port-forward -n ambassador svc/ambassador 8080:80 &

# start sending a request every three seconds
while true; do curl -H "HOST: helloworld-go.default.example.com" http://localhost:8080; sleep 3; done

# the stat command will show you the high level details of the resources in your cluster
linkerd stat deploy --all-namespaces

# see real-time requests being sent to resources
linkerd tap po --namespace default

# The tap command can provide output for deployments as well as pods.
linkerd tap deploy --namespace default

# more granular output, use specific pod names to see traffic between two pods
# linkerd tap po/<pod-name-1> --namespace default --to po/<pod-name-2>

#  mTLS is enabled by default.
# verify that the connections between the components are encrypted
linkerd edges deploy -n default

# The metrics command will dump all the prometheus metrics collected for a specified resource
# For example, this will output all the metrics collected for the deploy/activator resource in knative-serving
linkerd metrics --namespace knative-serving deploy/activator

# Dashboard
linkerd dashboard &
