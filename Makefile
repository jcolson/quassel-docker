NAME=k8r.eu/justjanne/quassel-docker
ALPINE_VERSION=3.10
QUASSEL_VERSION=
QUASSEL_BRANCH=master
ifeq ($(strip $(QUASSEL_VERSION)),)
IMAGE_VERSION=trunk
else
IMAGE_VERSION=v$(QUASSEL_VERSION)
endif

.PHONY: all
all: push

.PHONY: build
build: build_x86 build_aarch64 build_armhf

.PHONY: build_x86
build_x86: Dockerfile
	docker build \
		-t $(NAME):$(IMAGE_VERSION) \
		--build-arg BASE=alpine:$(ALPINE_VERSION) \
		--build-arg QUASSEL_VERSION=$(QUASSEL_VERSION) \
		--build-arg QUASSEL_BRANCH=$(QUASSEL_BRANCH) \
		.
	if [ ! -z "$(QUASSEL_VERSION)" ]; then docker tag $(NAME):$(IMAGE_VERSION) $(NAME):latest; fi

.PHONY: build_aarch64
build_aarch64: Dockerfile
	docker build \
		-t $(NAME):$(IMAGE_VERSION)-aarch64 \
		--build-arg BASE=multiarch/alpine:aarch64-v$(ALPINE_VERSION) \
		--build-arg QUASSEL_VERSION=$(QUASSEL_VERSION) \
		--build-arg QUASSEL_BRANCH=$(QUASSEL_BRANCH) \
		.
	if [ ! -z "$(QUASSEL_VERSION)" ]; then docker tag $(NAME):$(IMAGE_VERSION)-aarch64 $(NAME):aarch64; fi

.PHONY: build_armhf
build_armhf: Dockerfile
	docker build \
		-t $(NAME):$(IMAGE_VERSION)-armhf \
		--build-arg BASE=multiarch/alpine:armhf-v$(ALPINE_VERSION) \
		--build-arg QUASSEL_VERSION=$(QUASSEL_VERSION) \
		--build-arg QUASSEL_BRANCH=$(QUASSEL_BRANCH) \
		.
	if [ ! -z "$(QUASSEL_VERSION)" ]; then docker tag $(NAME):$(IMAGE_VERSION)-armhf $(NAME):armhf; fi

.PHONY: push
push: push_x86 push_aarch64 push_armhf

.PHONY: push_x86
push_x86: build_x86
	docker push $(NAME):$(IMAGE_VERSION)
	if [ ! -z "$(QUASSEL_VERSION)" ]; then docker push $(NAME):latest; fi

.PHONY: push_aarch64
push_aarch64: build_aarch64
	docker push $(NAME):$(IMAGE_VERSION)-aarch64
	if [ ! -z "$(QUASSEL_VERSION)" ]; then docker push $(NAME):aarch64; fi

.PHONY: push_armhf
push_armhf: build_armhf
	docker push $(NAME):$(IMAGE_VERSION)-armhf
	if [ ! -z "$(QUASSEL_VERSION)" ]; then docker push $(NAME):armhf; fi
