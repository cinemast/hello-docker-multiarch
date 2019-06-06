CXXFLAGS= -std=c++14 -O3 -Wall -Werror=format-security
HARDENINGFLAGS= -fstack-protector-strong -D_FORTIFY_SOURCE=2 -fpie

hello-world: main.cpp httplib.h
	g++ $(CXXFLAGS) $(HARDENINGFLAGS) main.cpp -o $@ -lpthread

build-image:
	docker build -t cinemast/hello-docker-multiarch .

run-image:
	docker run -p1234:1234 -it cinemast/hello-docker-multiarch /usr/bin/hello-world

clean:
	rm -f hello-world a.out