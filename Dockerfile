ARG target_arch
FROM ${target_arch}/alpine:latest AS builder
ARG qemu_bin
ADD $qemu_bin /usr/bin/
RUN /bin/mkdir /build
WORKDIR /build
COPY Makefile main.cpp httplib.h /build/
RUN apk add --no-cache g++ libc-dev make
RUN make hello-world

ARG target_arch
FROM ${target_arch}/alpine:latest
ARG qemu_bin
ADD $qemu_bin /usr/bin/
RUN apk add --no-cache libstdc++
RUN rm /usr/bin/qemu-*-static
COPY --from=builder /build/hello-world /usr/bin/hello-world
CMD ["/usr/bin/hello-world"]
