
NAME = madharjan/docker-base-template
VERSION = 1.0

DEBUG ?= true

.PHONY: all build run tests stop clean tag_latest release clean_images

all: build

build:
	docker build \
		--build-arg TEMPLATE_VERSION=$(VERSION) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg DEBUG=$(DEBUG) \
		-t $(NAME):$(VERSION) --rm .

run:
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
		-e DEBUG=${DEBUG} \
		--name template_no_template $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		-e DEBUG=${DEBUG} \
		--name template_default $(NAME):$(VERSION)

	sleep 3

tests:
	sleep 5
	./bats/bin/bats test/tests.bats

stop:
	docker exec template /bin/bash -c "sv stop template" || true
	sleep 2
	docker exec template /bin/bash -c "rm -rf /etc/template/*" || true
	docker exec template /bin/bash -c "rm -rf /var/lib/template/*" || true
	docker stop template template_no_template template_default || true

clean:stop
	docker rm template template_no_template template_default || true
	rm -rf /tmp/template || true
	docker images | grep "^<none>" | awk '{print$3 }' | xargs docker rmi || true

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: run tests clean tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag $(VERSION) && git push origin $(VERSION) ***"
	curl -s -X POST https://hooks.microbadger.com/images/$(NAME)/############################

clean_images:
	docker rmi $(NAME):latest $(NAME):$(VERSION) || true
