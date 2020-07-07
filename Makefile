IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-rio:
	bash app/deploy-rio.sh

deploy-minikube:
	bash app/deploy-minikube.sh

deploy-minikube-latest:
	bash app/deploy-minikube-latest.sh

deploy-openesb:
	bash app/deploy-openesb.sh

deploy-openfaas:
	bash app/deploy-openfaas.sh

deploy-linkerd:
	bash app/deploy-linkerd.sh

deploy-canary-linkerd:
	bash app/deploy-canary-linkerd.sh

deploy-canary:
	bash app/deploy-canary.sh

deploy-knative:
	bash app/deploy-knative.sh

deploy-bluegreen:
	bash app/deploy-bluegreen.sh

deploy-dashboard:
	bash app/deploy-dashboard.sh

deploy-java-maven:
	bash app/deploy-java-maven.sh

push-image:
	docker push $(IMAGE)

.PHONY: deploy-kind deploy-openesb deploy-dashboard deploy-minikube deploy-istio push-image
