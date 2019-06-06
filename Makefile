PROJECT=cinemast/hello-docker-multiarch
VERSION=1.0.0

CXXFLAGS= -std=c++14 -O3 -Wall -Werror=format-security
HARDENINGFLAGS= -fstack-protector-strong -D_FORTIFY_SOURCE=2 -fpie

ARCHES=amd64 arm64v8 arm32v6 armhf

hello-world: main.cpp httplib.h
	g++ $(CXXFLAGS) $(HARDENINGFLAGS) main.cpp -o $@ -lpthread


%:
	docker build --build-arg target_arch=$@ -t $(PROJECT):$@-latest -t $(PROJECT):$@-$(VERSION) .

run-image:
	docker run -p1234:1234 -it $(PROJECT)

manifest: push-images
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend $(PROJECT):latest $(PROJECT):arm64v8-latest $(PROJECT):arm32v6-latest $(PROJECT):amd64-latest
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend $(PROJECT):$(VERSION) $(PROJECT):arm64v8-$(VERSION) $(PROJECT):arm32v6-$(VERSION) $(PROJECT):amd64-$(VERSION)

images: $(ARCHES)

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