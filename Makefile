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
	#docker run --rm --privileged multiarch/qemu-user-static:register
	for target_arch in $(QEMU_ARCHS); do  done

build-image:
	docker build -t cinemast/hello-docker-multiarch .

%: qemu-aarch64-static
	docker build --squash --build-arg TARGET_ARCH=arm64v8 --build-arg QEMU_BIN=$< -t $@ .


run-image:
	docker run -p1234:1234 -it cinemast/hello-docker-multiarch /usr/bin/hello-world

clean:
	rm -f hello-world a.out qemu-*-static x86_64_qemu-*.tar.gz