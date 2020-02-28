JSONNET_URL   ?= https://github.com/google/jsonnet/releases/download/v0.15.0/jsonnet-bin-v0.15.0-linux.tar.gz

IP             = $(shell minikube ip)
GRAFANA_URL    = grafana.$(IP).nip.io
PROMETHEUS_URL = prometheus.$(IP).nip.io

PROM_OPTIONS = --set grafana.ingress.hosts[0]=$(GRAFANA_URL) --set prometheus.ingress.hosts[0]=$(PROMETHEUS_URL)

prereq:
	helm repo add stable https://kubernetes-charts.storage.googleapis.com
	k get ns monitoring > /dev/null|| k create ns monitoring

prom: prereq
	helm upgrade --install prom stable/prometheus-operator --namespace monitoring $(PROM_OPTIONS) -f prometheus-operator.yml

start:
	minikube start
stop:
	minikube stop

bin/jsonnet:
	mkdir -p bin
	cd bin && wget -q -O - $(JSONNET_URL) | tar xfz -

jsonnet/grafonnet-lib:
	git clone https://github.com/grafana/grafonnet-lib.git jsonnet/grafonnet-lib

grafonnet-lib: jsonnet/grafonnet-lib bin/jsonnet
	cd jsonnet/grafonnet-lib && git pull
