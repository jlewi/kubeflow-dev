# IMG is the base path for images..
# Individual images will be
# $(IMG)/$(NAME):$(TAG)
CONTEXT=label-bot-dev

PROJECT ?= code-search-demo
IMG ?= gcr.io/${PROJECT}/vscode

# List any changed  files. We only include files in the notebooks directory.
# because that is the code in the docker image.
# In particular we exclude changes to the ksonnet configs.
CHANGED_FILES := $(shell git diff-files)

# Whether to use cached images with GCB
USE_IMAGE_CACHE ?= true

ifeq ($(strip $(CHANGED_FILES)),)
# Changed files is empty; not dirty
# Don't include --dirty because it could be dirty if files outside the ones we care
# about changed.
GIT_VERSION := $(shell git describe --always)
else
GIT_VERSION := $(shell git describe --always)-dirty-$(shell git diff | shasum -a256 | cut -c -6)
endif

TAG := $(shell date +v%Y%m%d)-$(GIT_VERSION)
all: build

# To build without the cache set the environment variable
# export DOCKER_BUILD_OPTS=--no-cache
.PHONY: build
build-dir: ./Dockerfile requirements.txt
	mkdir  -p ./.build
	cp ./Dockerfile* ./.build/
	cp ./requirements* ./.build/

build: build-dir
	cd .build && docker build ${DOCKER_BUILD_OPTS} -t $(IMG):$(TAG) -f Dockerfile . \
           --label=git-verions=$(GIT_VERSION)
	docker tag $(IMG):$(TAG) $(IMG):latest
	@echo Built $(IMG):latest
	@echo Built $(IMG):$(TAG)

build-gcb: build-dir	
	gcloud builds submit --machine-type=n1-highcpu-32 --project=$(PROJECT) --tag=$(IMG):$(TAG) \
		--timeout=3600 ./.build
	@echo Built $(IMG):$(TAG)

push: build
	docker push $(IMG):$(TAG) 
	docker push $(IMG):latest


apply:
	# TODO(jlewi): What's the best way to make sure the statefulset pod gets kicked?
	# should we delete it manually or could we add a unique annotation?
	kustomize build | kubectl --context=$(CONTEXT) apply -f -
	kubectl --context=$(CONTEXT) \
		-n $(shell yq r Kptfile openAPI.definitions["io.k8s.cli.setters.namespace"].["x-k8s-cli"].setter.value) \
		delete pods jlewi-vscode-0