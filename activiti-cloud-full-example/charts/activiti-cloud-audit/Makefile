#CHART_REPO := http://jenkins-x-chartmuseum:8080
CURRENT=$(shell pwd)
NAME := activiti-cloud-audit
ORG := $(or $(ORG),activiti)
APP_NAME := $(or $(APP_NAME),$(NAME))
OS := $(shell uname)
RELEASE_VERSION := $(shell cat ../../VERSION)
RELEASE_ARTIFACT := $(or $(RELEASE_ARTIFACT),$(APP_NAME))

GITHUB_CHARTS_REPO := $(or $(GITHUB_CHARTS_REPO),$(shell git config --get remote.origin.url))
GITHUB_CHARTS_BRANCH := $(or $(GITHUB_CHARTS_BRANCH),gh-pages)
GITHUB_CHARTS_DIR:= $(or $(GITHUB_CHARTS_DIR),activiti-cloud-helm-charts)

build: clean
	helm init --client-only
	helm repo add charts_activiti https://activiti.github.io/activiti-cloud-charts/
	helm repo add activiti-cloud-helm-charts https://activiti.github.io/activiti-cloud-helm-charts/
	helm dependency build
	helm lint
	helm install . --name ${NAME} --debug --dry-run

install:  build
	helm install . --name ${NAME}

upgrade: clean build
	helm upgrade ${NAME} .

delete:
	helm delete --purge ${NAME}

clean:
	rm -rf requirements.lock
	rm -rf charts
	rm -rf ${NAME}*.tgz

release: build
	helm package .
#	curl  -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-$(shell sed -n 's/^version: //p' Chart.yaml).tgz" $(CHART_REPO)/api/charts
#	rm -rf ${NAME}*.tgz%
push:
	for i in {0..20}; do \
	   	cd $(GITHUB_CHARTS_DIR) && \
	   	git push origin "$(GITHUB_CHARTS_BRANCH)"; \
	   	[[ $$? == 0 ]]&&exit 0; \
	   	echo git push try $$i; \
	done

github:
	$(eval GITHUB_CHARTS_DIR := $(shell basename $(GITHUB_CHARTS_REPO) .git))
	[[ -d $(GITHUB_CHARTS_DIR) ]] ||git clone -b "$(GITHUB_CHARTS_BRANCH)" "$(GITHUB_CHARTS_REPO)" $(GITHUB_CHARTS_DIR)
	cp "$(NAME)-$(RELEASE_VERSION).tgz" $(GITHUB_CHARTS_DIR)
	cd $(GITHUB_CHARTS_DIR) && \
	   helm repo index . && \
	   git add . && \
	   git status && \
	   git commit -m "fix:(version) release $(NAME)-$(RELEASE_VERSION).tgz" && \
	   git pull ;
	$(MAKE) push
	rm -rf $(GITHUB_CHARTS_DIR)

tag:
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(RELEASE_VERSION)/" Chart.yaml
	sed -i "" -e "s/tag: .*/tag: $(RELEASE_VERSION)/" values.yaml
else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(RELEASE_VERSION)/" Chart.yaml
	sed -i -e "s|repository: .*|repository: $(DOCKER_REGISTRY)/$(ORG)/$(APP_NAME)|" values.yaml
	sed -i -e "s/tag: .*/tag: $(RELEASE_VERSION)/" values.yaml
else
	echo "platfrom $(OS) not supported to release from"
	exit -1
endif
	git add --all
	git commit -m "release $(RELEASE_VERSION)" --allow-empty # if first release then no verion update is performed
	git tag -fa v$(RELEASE_VERSION) -m "Release version $(RELEASE_VERSION)"
	git push origin v$(RELEASE_VERSION)

updatebot/push-version: 
	@echo Resolving push versions for artifacts........
	$(eval ACTIVITI_CLOUD_DEPENDENCIES_VERSION=$(shell mvn help:evaluate -Dexpression=activiti-cloud-dependencies.version -q -DforceStdout -f ../../pom.xml))
	
	@echo Doing updatebot push-version.....
	cd ../../ && updatebot push-version --kind helm $(RELEASE_ARTIFACT) $(RELEASE_VERSION)
	cd ../../ && updatebot push-version --kind make AUDIT_ACTIVITI_CLOUD_DEPENDENCIES_VERSION $(ACTIVITI_CLOUD_DEPENDENCIES_VERSION)
	cd ../../ && rm -rf .updatebot-repos/
	sleep $$[ ( $$RANDOM % 10 )  + 1 ]s
	cd ../../ && updatebot push-version --kind helm $(RELEASE_ARTIFACT) $(RELEASE_VERSION)
	cd ../../ && updatebot push-version --kind make AUDIT_ACTIVITI_CLOUD_DEPENDENCIES_VERSION $(ACTIVITI_CLOUD_DEPENDENCIES_VERSION)

