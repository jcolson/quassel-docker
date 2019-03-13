NAME=k8r.eu/justjanne/quassel-docker
QUASSEL_VERSION=v0.13.1
ALPINE_VERSION=3.9

.PHONY: build
build: build_x86 build_arm64v8 build_arm32v6

.PHONY: build_x86
build_x86: Dockerfile
	docker build -t $(NAME):$(QUASSEL_VERSION) --build-arg BASE=alpine:$(ALPINE_VERSION) .
	docker tag $(NAME):$(QUASSEL_VERSION) $(NAME):latest

.PHONY: build_arm64v8
build_arm64v8: Dockerfile
	docker build -t $(NAME):$(QUASSEL_VERSION)-arm64v8 --build-arg BASE=multiarch/alpine:aarch64-v$(ALPINE_VERSION) .
	docker tag $(NAME):$(QUASSEL_VERSION)-arm64v8 $(NAME):arm64v8

.PHONY: build_arm32v6
build_arm32v6: Dockerfile
	docker build -t $(NAME):$(QUASSEL_VERSION)-arm32v6 --build-arg BASE=multiarch/alpine:armhf-v$(ALPINE_VERSION) .
	docker tag $(NAME):$(QUASSEL_VERSION)-arm32v6 $(NAME):arm32v6

.PHONY: push
push: push_x86 push_arm64v8 push_arm32v6

.PHONY: push_x86
push_x86: build_x86
	docker push $(NAME):$(QUASSEL_VERSION)
	docker push $(NAME):latest

.PHONY: push_arm64v8
push_arm64v8: build_arm64v8
	docker push $(NAME):$(QUASSEL_VERSION)-arm64v8
	docker push $(NAME):arm64v8

.PHONY: push_arm32v6
push_arm32v6: build_arm32v6
	docker push $(NAME):$(QUASSEL_VERSION)-arm32v6
	docker push $(NAME):arm32v6
