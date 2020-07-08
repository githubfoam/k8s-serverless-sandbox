IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-kind:
	bash kind/deploy-kind.sh

deploy-minikube:
	bash minikube/deploy-minikube.sh

deploy-minikube-latest:
	bash minikube/deploy-minikube-latest.sh

deploy-openfaas:
	bash app/deploy-openfaas.sh

deploy-knative:
	bash app/deploy-knative.sh

push-image:
	docker push $(IMAGE)

.PHONY: deploy-kind deploy-openesb deploy-dashboard deploy-minikube deploy-istio push-image
