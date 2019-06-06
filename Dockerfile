FROM alpine:latest AS builder
RUN /bin/mkdir /build
WORKDIR /build
COPY Makefile main.cpp httplib.h /build/
RUN apk add --no-cache g++ libc-dev make
RUN make hello-world

ARG target_arch
FROM alpine:latest
RUN apk add --no-cache libstdc++
COPY --from=builder /build/hello-world /usr/bin/hello-world
CMD ["/usr/bin/hello-world"]
