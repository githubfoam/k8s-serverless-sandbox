#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

#https://github.com/redhat-developer-demos/quarkus-pipeline-demo
echo "============================Serverless and Pipelines=============================================================="

# https://github.com/mikefarah/yq/
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64
add-apt-repository -y ppa:rmescandon/yq
apt-get update -qq && apt-get install yq -yqq

# https://github.com/ahmetb/kubectx/blob/master/kubens
# /bin/bash -c "$(curl -fsSL https://github.com/ahmetb/kubectx/blob/master/kubens)" # /bin/bash: Argument list too long
# /bin/bash -c '$(curl -fsSL https://github.com/ahmetb/kubectx/blob/master/kubens)'
# https://github.com/ahmetb/kubectx
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# https://github.com/tektoncd/cli
# Get the tar.xz
curl -LO https://github.com/tektoncd/cli/releases/download/v0.10.0/tkn_0.10.0_Darwin_x86_64.tar.gz
# Extract tkn to your PATH (e.g. /usr/local/bin)
tar xvzf tkn_0.10.0_Darwin_x86_64.tar.gz -C /usr/local/bin tkn

minikube addons enable registry
# kubectl -n kube-system get pods -w # interactive shell
kubectl get pods --all-namespaces
echo echo "Waiting for the registry pod to be ready ..."
for i in {1..150}; do # Timeout after 5 minutes, 60x5=300 secs
      if kubectl get pods --namespace=kube-system  | grep ContainerCreating ; then
        sleep 10
      else
        break
      fi
done
kubectl get pods --all-namespaces


# Configure registry aliases
# push and pull images from internal registry
# make the registry entry in minikube node’s hosts file and make them resolvable via coredns
git clone https://github.com/kameshsampath/minikube-helpers.git && cd minikube-helpers/registry

# Add entries to host file
# All the registry aliases are configured using the configmap registry-aliases-config.yaml
# create the configmap in kube-system namespace:
kubectl apply -n kube-system -f registry-aliases-config.yaml
# run the dameonset node-etc-hosts-update.yaml
# add entries to the minikube node’s /etc/hosts file with all aliases pointing to internal registrys' CLUSTER_IP
kubectl apply -n kube-system -f node-etc-hosts-update.yaml
echo echo "Waiting for the daemonset pod to be ready ..."
for i in {1..150}; do # Timeout after 5 minutes, 60x5=300 secs
      if kubectl get pods --namespace=kube-system  | grep ContainerCreating ; then
        sleep 10
      else
        break
      fi
done
kubectl get pods --all-namespaces


# check the minikube vm’s /etc/hosts file for the registry aliases entries
# the daemonset has added the registryAliases from the ConfigMap pointing to the internal registry’s CLUSTER-IP.
# minikube ssh -- sudo cat /etc/hosts #none' driver does not support 'minikube ssh' command


# Update the Kubernetes' coredns to have rewrite rules for aliases.
# bash patch-coredns.sh
# verify
# Once successfully patched push and pull from the registry using suffix dev.local, example.com
# kubectl get cm -n kube-system coredns -o yaml


# Install Tekton Pipelines
# kubectl apply --filename https://storage.googleapis.com/tekton-releases/latest/release.yaml
# echo echo "Waiting for the Tekton Pipelines Pods to be ready ..."
# for i in {1..150}; do # Timeout after 5 minutes, 60x5=300 secs
#       if kubectl get pods --namespace=tekton-pipelines  | grep ContainerCreating ; then
#         sleep 10
#       else
#         break
#       fi
# done


# Install Knative Serving
# `curl -L  https://raw.githubusercontent.com/knative/serving/release-0.6/third_party/istio-1.1.3/istio-lean.yaml \
#   | sed 's/LoadBalancer/NodePort/' \
#   | kubectl apply --filename -`
# curl -L  https://raw.githubusercontent.com/knative/serving/release-0.6/third_party/istio-1.1.3/istio-lean.yaml | \
#   sed 's/LoadBalancer/NodePort/' | \
#   kubectl apply --filename -
# curl -L  https://raw.githubusercontent.com/knative/serving/release-0.6/third_party/istio-1.1.3/istio-lean.yaml \
#   | sed 's/LoadBalancer/NodePort/' \
#   | kubectl apply --filename -
#   echo echo "Waiting for the Istio Pods to be ready ..."
#   for i in {1..150}; do # Timeout after 5 minutes, 60x5=300 secs
#         if kubectl get pods --namespace=isito-system  | grep ContainerCreating ; then
#           sleep 10
#         else
#           break
#         fi
#   done

  # kubectl apply --selector knative.dev/crd-install=true \
  # --filename https://github.com/knative/serving/releases/download/v0.6.0/serving.yaml \
  # --filename https://github.com/knative/serving/releases/download/v0.6.0/serving.yaml --selector networking.knative.dev/certificate-provider!=cert-manager
  #
  # echo echo "Waiting for the Knative Serving Pods to be ready ..."
  # for i in {1..150}; do # Timeout after 5 minutes, 60x5=300 secs
  #       if kubectl get pods --namespace=knative-serving  | grep ContainerCreating ; then
  #         sleep 10
  #       else
  #         break
  #       fi
  # done



# Configure Pipelines
# Download the demo sources and lets call the folder as $PROJECT_HOME
# As the build need to be run with service account that needs permissions to create resources, a new service account 'build-robot' needs to be created with required permissions
git clone https://redhat-developer-demos/quarkus-pipeline-demo &&\
cd quarkus-pipeline-demo &&\
export PROJECT_HOME=`pwd`

# All the objects will be created in the namespace called demos, if you wish to change it please edit the file build/build-roles.yaml and update the namespace name.
kubectl apply -f $PROJECT_HOME/build/build-roles.yaml
# Change to the demos namespace
kubens demos


# The build uses resources called PipelineResource that helps to configure the git repo url, the final container image name etc.
# create the resources
kubectl apply -f $PROJECT_HOME/build/build-resources.yaml


# The Pipeline consists of multiple tasks that needs to be executed in order.
# create the pipeline tasks
kubectl apply --recursive -f $PROJECT_HOME/build/tasks
# list the created tasks.
tkn task list


# create the pipeline that uses the tasks  in the previous step
kubectl apply --recursive -f $PROJECT_HOME/build/pipelines
# list the created tasks
tkn pipeline list



# make the pipeline run, we need to create the PipelineRun
# https://github.com/tektoncd/pipeline/blob/master/docs/pipelineruns.md
# create the pipelinerun that uses the one of pipelines e.g. greeter-pipeline-jvm created in the previous step
kubectl apply  -f $PROJECT_HOME/build/pipelinerun/greeter-pipeline-run.yaml
# to do a native build then update the pipelineRef in greeter-pipeline-run.yaml to be greeter-pipeline-native
# list the created tasks
tkn pipelinerun list
#view the logs of the pipeline
tkn pipelinerun logs -f -a greeter-pipeline-run


# a local maven repo manager like Nexus then you can configure the pipeline to use it via the param mavenMirrorUrl e.g.
# Assuming your nexus repository is running in http://192.168.99.1:8081
#  params:
#     - name: mavenMirrorUrl
#       value: http://192.168.99.1:8081/nexus/content/groups/public #(1)


# deploy an application called "greeter"
kubectl get -n demos deployments
# a correponding service called greeter-service
kubectl get -n demos services




# Deploying Knative Service
# deploy Knative service using the same pipelines, edit the ./build/pipelinerun/greeter-pipeline-run.yaml and update
