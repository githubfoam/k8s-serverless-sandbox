IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-microk8s:
	bash platform/deploy-microk8s.sh

deploy-k3d:
	bash platform/deploy-k3d.sh

deploy-kind:
	bash platform/deploy-kind.sh

deploy-minikube:
	bash platform/deploy-minikube.sh

deploy-minikube-latest:
	bash platform/deploy-minikube-latest.sh

deploy-openfaas-golang:
	bash app/deploy-openfaas-golang.sh

deploy-linkerd-openfaas:
	bash app/deploy-linkerd-openfaas

deploy-openfaas:
	bash app/deploy-openfaas.sh

deploy-linkerd-knative-kourier:
	bash app/deploy-linkerd-knative-kourier

deploy-linkerd-knative-kong:
	bash app/deploy-linkerd-knative-kong

deploy-linkerd-knative-gloo:
	bash app/deploy-linkerd-knative-gloo

deploy-linkerd-knative-contour:
	bash app/deploy-linkerd-knative-contour

deploy-linkerd-knative-ambassador:
	bash app/deploy-linkerd-knative-ambassador

deploy-istio-knative:
	bash app/deploy-istio-knative.sh

deploy-knative:
	bash app/deploy-knative.sh

push-image:
	docker push $(IMAGE)

.PHONY: deploy-kind deploy-openesb deploy-dashboard deploy-minikube deploy-istio push-image
