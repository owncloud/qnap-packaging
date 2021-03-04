SHELL              := /bin/bash
BUILDER_IMAGE_NAME := qnap/qpkg-builder
BUILD_DIR          := build
SUPPORT_ARCH       := x86_64
CODESIGNING_TOKEN  ?=

COLOR_YELLOW       := \033[33m
COLOR_BLUE         := \033[34m
COLOR_RESET        := \033[0m

.PHONY: build
build: docker-builder
	@if [ ! -f /.dockerenv ]; then \
		docker run --rm -t --name=build-owncloud-qpkg-$$$$ \
			-e QNAP_CODESIGNING_TOKEN=$(CODESIGNING_TOKEN) \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $(PWD):/work \
			$(BUILDER_IMAGE_NAME) make _build; \
	else \
		$(MAKE) -$(MAKEFLAGS) _build; \
	fi

.PHONY: _build
_build: docker-images
	@echo -e "$(COLOR_BLUE)### Build QPKG ...$(COLOR_RESET)"
	/usr/share/qdk2/QDK/bin/qbuild --build-dir $(BUILD_DIR)

.PHONY: docker-builder
docker-builder:
	@echo -e "$(COLOR_BLUE)### Prepare QPKG builder: $(BUILDER_IMAGE_NAME)$(COLOR_RESET)"
	docker build -t $(BUILDER_IMAGE_NAME) .

.PHONY: docker-images
docker-images:
# TODO reenable image packing??
#docker-images: docker-images-x86_64 docker-images-arm32v7

.PHONY: docker-images-x86_64
docker-images-x86_64:
	rm -rf data/x86_64/docker-images
	@for img in $(shell awk -F'image: ' '/image:/ {print $$2}' data/x86_64/docker-compose.yml); do \
		tarball=$$(echo $${img} | sed -e 's?/?-?' -e 's?:?_?').tar; \
		echo -e "$(COLOR_BLUE)### Download container image: $${img}$(COLOR_RESET)"; \
		docker pull $${img}; \
		echo -e "$(COLOR_YELLOW)### Save container image to a tar archive: $${tarball}$(COLOR_RESET)"; \
		mkdir -p data/x86_64/docker-images; \
		echo $${img} >> data/x86_64/docker-images/DOCKER_IMAGES; \
		docker save -o data/x86_64/docker-images/$${tarball} $${img}; \
	done

.PHONY: docker-images-arm32v7
docker-images-arm32v7:
	rm -rf data/arm32v7/docker-images
	@for img in $(shell awk -F'image: ' '/image:/ {print $$2}' data/arm32v7/docker-compose.yml); do \
		tarball=$$(echo $${img} | sed -e 's?/?-?' -e 's?:?_?').tar; \
		echo -e "$(COLOR_BLUE)### Download container image: $${img}$(COLOR_RESET)"; \
		docker pull $${img}; \
		echo -e "$(COLOR_YELLOW)### Save container image to a tar archive: $${tarball}$(COLOR_RESET)"; \
		mkdir -p data/arm32v7/docker-images; \
		echo $${img} >> data/arm32v7/docker-images/DOCKER_IMAGES; \
		docker save -o data/arm32v7/docker-images/$${tarball} $${img}; \
	done

.PHONY: clean
clean:
	@echo -e "$(COLOR_BLUE)### Remove build files ...$(COLOR_RESET)"
	rm -rf data/*/docker-images
	rm -rf build{,.*}/ tmp.*/
