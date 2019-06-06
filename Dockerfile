ARG TARGET_ARCH
ARG QEMU_BIN
FROM ${TARGET_ARCH}/alpine:latest AS builder
COPY ${QEMU_BIN} /usr/bin/
RUN /bin/mkdir /build
WORKDIR /build
COPY Makefile main.cpp httplib.h /build/
RUN apk add --no-cache g++ libc-dev make
RUN make hello-world

FROM ${TARGET_ARCH}/alpine:latest
COPY ${QEMU_BIN} /usr/bin/
RUN apk add --no-cache libstdc++
RUN rm /usr/bin/qemu-*-static
COPY --from=builder /build/hello-world /usr/bin/hello-world
CMD ["/usr/bin/hello-world"]
