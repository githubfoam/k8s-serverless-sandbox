IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-minikube-latest:
	bash app/deploy-minikube-latest.sh

deploy-openfaas:
	bash app/deploy-openfaas.sh


push-image:
	docker push $(IMAGE)

.PHONY: deploy-openfaas deploy-minikube-latest push-image
