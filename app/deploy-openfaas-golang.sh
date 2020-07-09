#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "============================OpenFaaS =============================================================="
# https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew install go faas-cli kubernetes-cli kubernetes-helm

# Deploy OpenFaaS to minikube
# Create a service account for Helm’s server component (tiller):
kubectl -n kube-system create sa tiller && kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

# Install tiller which is Helm’s server-side component:
helm init --skip-refresh --upgrade --service-account tiller

# Create namespaces for OpenFaaS core components and OpenFaaS Functions:
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.ym

# Add the OpenFaaS helm repository:
helm repo add openfaas https://openfaas.github.io/faas-netes/

# Update all the charts for helm:
helm repo update

# Create a password (Remember this for login to OpenFaaS dashboard):
# export PASSWORD=testpassword

# Random password example:
export PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)

# Create a secret for the password:
kubectl -n openfaas create secret generic basic-auth --from-literal=basic-auth-user=admin --from-literal=basic-auth-password="$PASSWORD"

# Install OpenFaaS using the chart:
helm upgrade openfaas --install openfaas/openfaas --namespace openfaas --set functionNamespace=openfaas-fn --set basic_auth=true

# Finally once all the Pods are started you can login using the faas-cli:
echo -n $PASSWORD | faas-cli login -g http://$(minikube ip):31112 -u admin --password-stdin

 # find dashboard URL and open it by browser (username: admin)
 echo http://$(minikube ip):31112


# Use faas-cli
# Generate a Go function
# generate a go-fn directory contains a simple template function response like this
# "Hello, Go. You said: (request body)"
# and a go-fn.yml file in working directory
faas-cli new go-fn --lang go
ls -lai
cat go-fn.yml

# Build function
# Add Docker Hub username to go-fn.yml file's image tag
# Build docker image:
# find go-fn in your Docker Hub repository
# faas-cli build -f go-fn.yml
# Push to Docker Hub:
# faas-cli push -f go-fn.yml

# Deploy function
# faas-cli deploy -f go-fn.yml --gateway http://$(minikube ip):31112

# see this function in the dashboard
# Invoke it by using dashboard UI or using faas-cli
# echo test | faas-cli invoke go-fn --gateway http://$(minikube ip):31112

# Build, push and deploy can use just one command to finish these step
# faas-cli up -f go-fn.yml --gateway http://$(minikube ip):31112
