FROM alpine:latest AS builder
RUN mkdir /build
WORKDIR /build
COPY Makefile main.cpp httplib.h /build/
RUN apk add g++ libc-dev make
RUN make hello-world

FROM alpine:latest
RUN apk add libstdc++
COPY --from=builder /build/hello-world /usr/bin/hello-world
CMD ["/usr/bin/hello-world"]
