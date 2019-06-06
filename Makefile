PROJECT=cinemast/hello-docker-multiarch
VERSION=1.0.0

CXXFLAGS= -std=c++14 -O3 -Wall -Werror=format-security
HARDENINGFLAGS= -fstack-protector-strong -D_FORTIFY_SOURCE=2 -fpie

QEMU_BASEURL=https://github.com/multiarch/qemu-user-static/releases/download/v4.0.0-2
ARCHES=amd64 arm64v8 arm32v6 s390x

hello-world: main.cpp httplib.h
	g++ $(CXXFLAGS) $(HARDENINGFLAGS) main.cpp -o $@ -lpthread

%: qemu-%-static
	docker build -f Dockerfile.cross --build-arg target_arch=$@ -t $(PROJECT):$@-latest -t $(PROJECT):$@-$(VERSION) .

amd64:
	docker build -t $(PROJECT):$@-latest -t $(PROJECT):$@-$(VERSION) .

qemu-%-static:
	wget $(QEMU_BASEURL)/$@

qemu-arm64v8-static:
	wget $(QEMU_BASEURL)/qemu-aarch64-static -O $@

qemu-arm32v6-static:
	wget $(QEMU_BASEURL)/qemu-arm-static -O $@

run-image:
	docker run -p1234:1234 -it $(PROJECT)

manifest:
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend $(PROJECT):latest $(shell printf "$(PROJECT):%s-latest " $(ARCHES))
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend $(PROJECT):$(VERSION)  $(shell printf "$(PROJECT):%s-$(VERSION) " $(ARCHES))

images: $(ARCHES)

push-images:
	for arch in $(ARCHES); do docker push $(PROJECT):$$arch-$(VERSION); docker push $(PROJECT):$$arch-latest; done

push-manifests: manifest
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push $(PROJECT):latest
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push $(PROJECT):$(VERSION)

push: push-images push-manifests

clean:
	rm -f hello-world a.out qemu-*-static
	docker images | grep $(PROJECT) | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi $(PROJECT):{}