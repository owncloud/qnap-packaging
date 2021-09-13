SHELL              := /bin/sh
BUILDER_IMAGE_NAME := owncloudci/qnap-qpkg-builder
BUILD_DIR          := build
SUPPORT_ARCH       := x86_64
CODESIGNING_TOKEN  ?=

COLOR_YELLOW       := \033[33m
COLOR_BLUE         := \033[34m
COLOR_RESET        := \033[0m

.PHONY: build
build: docker-images _build

.PHONY: build-qpkg-only
build-qpkg-only: _build

.PHONY: _build
_build:
	@if [ ! -f /.dockerenv ]; then \
		docker run --rm -t --name=build-owncloud-qpkg-$$$$ \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $(PWD):/work \
			$(BUILDER_IMAGE_NAME) make _build; \
    else \
		echo "$(COLOR_BLUE)### Build QPKG ...$(COLOR_RESET)"; \
		/usr/share/qdk2/QDK/bin/qbuild --build-dir $(BUILD_DIR); \
    fi

.PHONY: docker-images
docker-images: docker-images-linux_amd64 docker-images-linux_arm_v7

.PHONY: docker-images-linux_amd64
docker-images-linux_amd64:
	rm -rf data/linux_amd64/docker-images
	@for img in $(shell awk -F'image: ' '/image:/ {print $$2}' data/linux_amd64/docker-compose.yml); do \
		ref=$$(echo $${img} | sed -e 's/\(:\).*\(@\)/\1\2/' | sed 's/://'); \
		tarball=$${img//[^[:alnum:]]/_}.tar; \
		echo "$(COLOR_YELLOW)### Save container image to a tar archive: $${tarball}$(COLOR_RESET)"; \
		mkdir -p data/linux_amd64/docker-images; \
		echo $${img} >> data/linux_amd64/docker-images/DOCKER_IMAGES; \
		skopeo --insecure-policy copy docker://$${ref} docker-archive:./data/linux_amd64/docker-images/$${tarball}; \
	done

.PHONY: docker-images-linux_arm_v7
docker-images-linux_arm_v7:
	rm -rf data/linux_arm_v7/docker-images
	@for img in $(shell awk -F'image: ' '/image:/ {print $$2}' data/linux_arm_v7/docker-compose.yml); do \
		ref=$$(echo $${img} | sed -e 's/\(:\).*\(@\)/\1\2/' | sed 's/://'); \
		tarball=$${img//[^[:alnum:]]/_}.tar; \
		echo "$(COLOR_YELLOW)### Save container image to a tar archive: $${tarball}$(COLOR_RESET)"; \
		mkdir -p data/linux_arm_v7/docker-images; \
		echo $${img} >> data/linux_arm_v7/docker-images/DOCKER_IMAGES; \
		skopeo --insecure-policy copy docker://$${ref} docker-archive:./data/linux_arm_v7/docker-images/$${tarball}; \
	done

.PHONY: clean
clean:
	@echo "$(COLOR_BLUE)### Remove build files ...$(COLOR_RESET)"
	rm -rf data/*/docker-images
	rm -rf build{,.*}/ tmp.*/
