PROJECT=cinemast/hello-docker-multiarch
VERSION=1.0.0

CXXFLAGS= -std=c++14 -O3 -Wall -Werror=format-security
HARDENINGFLAGS= -fstack-protector-strong -D_FORTIFY_SOURCE=2 -fpie

hello-world: main.cpp httplib.h
	g++ $(CXXFLAGS) $(HARDENINGFLAGS) main.cpp -o $@ -lpthread


qemu-%-static:
	wget -N https://github.com/multiarch/qemu-user-static/releases/download/v2.9.1-1/x86_64_$@.tar.gz
	tar -xvf x86_64_$@.tar.gz

deps:
	docker run --rm --privileged multiarch/qemu-user-static:register

amd64:
	docker build -f Dockerfile.amd64 -t $(PROJECT):$@-latest -t $(PROJECT):$@-$(VERSION) .

arm64v8: qemu-aarch64-static
	docker build --build-arg target_arch=$@ --build-arg qemu_bin=$< -t $(PROJECT):$@-latest -t $(PROJECT):$@-$(VERSION) .

arm32v6: qemu-arm-static
	docker build --build-arg target_arch=$@ --build-arg qemu_bin=$< -t $(PROJECT):$@-latest -t $(PROJECT):$@-$(VERSION) .

run-image:
	docker run -p1234:1234 -it cinemast/hello-docker-multiarch /usr/bin/hello-world

manifest:
	docker manifest create --amend $(PROJECT):latest $(PROJECT):arm64v8-latest $(PROJECT):arm32v6-latest $(PROJECT):amd64-latest
	docker manifest create --amend $(PROJECT):$(VERSION) $(PROJECT):arm64v8-$(VERSION) $(PROJECT):arm32v6-$(VERSION) $(PROJECT):amd64-$(VERSION)

images: arm64v8 arm32v6 amd64
	docker manifest create $(PROJECT):arm64v8 $(PROJECT):arm32v6 $(PROJECT):amd64

push-images:
	docker push $(PROJECT):arm64v8-latest
	docker push $(PROJECT):arm64v8-$(VERSION)
	docker push $(PROJECT):arm32v6-latest
	docker push $(PROJECT):arm32v6-$(VERSION)
	docker push $(PROJECT):amd64-latest
	docker push $(PROJECT):amd64-$(VERSION)

push-manifests: manifest
	docker manifest push $(PROJECT):latest
	docker manifest push $(PROJECT):$(VERSION)

push: push-images push-manifests
	

clean:
	rm -f hello-world a.out qemu-*-static x86_64_qemu-*.tar.gz
	docker images | grep $(PROJECT) | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi $(PROJECT):{}