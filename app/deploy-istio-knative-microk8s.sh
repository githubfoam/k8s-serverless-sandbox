#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

#https://microk8s.io/#get-started
#https://microk8s.io/docs
#https://istio.io/docs/setup/platform-setup/microk8s/
#https://linkerd.io/2020/03/23/serverless-service-mesh-with-knative-and-linkerd/
#knative: Adds the Knative middleware to your cluster (not available on arm64 arch).
echo "=============================deploy istio knative ============================================================="

#ERRO[0000] could not set namespace from kubectl context: ensure a valid KUBECONFIG path has been set
microk8s.enable istio

# The connection to the server 127.0.0.1:16443 was refused - did you specify the right host or port?
# echo "Waiting for  istio to be ready ..."
# for i in {1..60}; do # Timeout after 3 minutes, 60x5=300 secs
#      if microk8s kubectl get pods --namespace=istio-system   | grep ContainerCreating ; then
#          sleep 5
#      else
#          break
#      fi
# done

# The connection to the server 127.0.0.1:16443 was refused - did you specify the right host or port?
# microk8s kubectl get pods --all-namespaces
# microk8s kubectl get pod -o wide #The IP column will contain the internal cluster IP address for each pod.
# microk8s kubectl get service --all-namespaces # find a Service IP,list all services in all namespaces
# microk8s kubectl get nodes
# microk8s kubectl get services
# echo "=============================deploy knative============================================================="
# microk8s status
# microk8s.enable knative
# echo "Waiting for  knative-serving to be ready ..."
# for i in {1..60}; do # Timeout after 3 minutes, 60x5=300 secs
#      if microk8s kubectl get pods --namespace=knative-serving   | grep ContainerCreating ; then
#          sleep 10
#      else
#          break
#      fi
# done

# echo "Waiting for  knative-eventing  to be ready ..."
# for i in {1..60}; do # Timeout after 3 minutes, 60x5=300 secs
#      if microk8s kubectl get pods --namespace=knative-eventing    | grep ContainerCreating ; then
#          sleep 10
#      else
#          break
#      fi
# done

# microk8s kubectl get pods --all-namespaces
# microk8s kubectl get pod -o wide #The IP column will contain the internal cluster IP address for each pod.

# #The connection to the server 127.0.0.1:16443 was refused - did you specify the right host or port?
# #microk8s kubectl get service --all-namespaces # find a Service IP,list all services in all namespaces

# microk8s kubectl get nodes
# microk8s kubectl get services
# microk8s status
# microk8s status | grep enabled
