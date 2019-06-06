
NAME = madharjan/docker-base-template
VERSION = 1.0

DEBUG ?= true

DOCKER_USERNAME ?= $(shell read -p "DockerHub Username: " pwd; echo $$pwd)
DOCKER_PASSWORD ?= $(shell stty -echo; read -p "DockerHub Password: " pwd; stty echo; echo $$pwd)
DOCKER_LOGIN ?= $(shell cat ~/.docker/config.json | grep "docker.io" | wc -l)

.PHONY: all build run test stop clean tag_latest release clean_images

all: build

docker_login:
ifeq ($(DOCKER_LOGIN), 1)
		@echo "Already login to DockerHub"
else
		@docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)
endif

build:
	sed -i -e "s/VERSION=.*/VERSION=$(VERSION)/g" bin/template-systemd-unit
	sed -i -e "s/TEMPLATE_VERSION=.*/TEMPLATE_VERSION=$(VERSION)/g" services/template/template.sh
	docker build \
		--build-arg TEMPLATE_VERSION=$(VERSION) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg DEBUG=$(DEBUG) \
		-t $(NAME):$(VERSION) --rm .

run:
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi

	rm -rf /tmp/template
	mkdir -p /tmp/template

	docker run -d \
		-e DEBUG=$(DEBUG) \
		-e TEMPLATE_USERNAME=myuser \
		-e TEMPLATE_PASSWORD=mypass \
		-v /tmp/template/etc/:/etc/template/ \
		-v /tmp/template/lib:/var/lib/template/ \
		--name template $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		-e DISABLE_TEMPLATE=1 \
		-e DEBUG=$(DEBUG) \
		--name template_no_template $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		-e DEBUG=$(DEBUG) \
		--name template_default $(NAME):$(VERSION)

	sleep 3

test:
	sleep 5
	./bats/bin/bats test/tests.bats

stop:
	docker exec template /bin/bash -c "sv stop template" 2> /dev/null || true
	sleep 2
	docker exec template /bin/bash -c "rm -rf /etc/template/*" 2> /dev/null || true
	docker exec template /bin/bash -c "rm -rf /var/lib/template/*" 2> /dev/null || true
	docker stop template template_no_template template_default 2> /dev/null || true

clean: stop
	docker rm template template_no_template template_default 2> /dev/null || true
	rm -rf /tmp/template || true
	docker images | grep "<none>" | awk '{print$3 }' | xargs docker rmi 2> /dev/null || true

publish: docker_login run test clean
	docker push $(NAME)

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: docker_login  run test clean tag_latest
	docker push $(NAME)

clean_images: clean
	docker rmi $(NAME):latest $(NAME):$(VERSION) 2> /dev/null || true
	docker logout 


