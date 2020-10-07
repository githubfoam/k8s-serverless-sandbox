IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-istio-knative-microk8s:
	bash app/deploy-istio-knative-microk8s.sh

deploy-microk8s:
	bash platform/deploy-microk8s.sh

deploy-k3d:
	bash platform/deploy-k3d.sh

deploy-kind-kubectl-helm:
	bash platform/deploy-kind-kubectl-helm.sh

deploy-kind:
	bash platform/deploy-kind.sh

deploy-minikube:
	bash platform/deploy-minikube.sh

deploy-minikube-latest:
	bash platform/deploy-minikube-latest.sh

deploy-openfaas-golang:
	bash app/deploy-openfaas-golang.sh

deploy-linkerd-openfaas:
	bash app/deploy-linkerd-openfaas.sh

deploy-openfaas:
	bash app/deploy-openfaas.sh

deploy-linkerd-knative-kourier:
	bash app/deploy-linkerd-knative-kourier.sh

deploy-linkerd-knative-kong:
	bash app/deploy-linkerd-knative-kong.sh

deploy-linkerd-knative-gloo:
	bash app/deploy-linkerd-knative-gloo.sh

deploy-linkerd-knative-contour:
	bash app/deploy-linkerd-knative-contour.sh

deploy-linkerd-knative-ambassador:
	bash app/deploy-linkerd-knative-ambassador.sh

deploy-istio-knative:
	bash app/deploy-istio-knative.sh

deploy-knative:
	bash app/deploy-knative.sh

push-image:
	docker push $(IMAGE)

.PHONY: deploy-kind deploy-openesb deploy-dashboard deploy-minikube deploy-istio push-image
