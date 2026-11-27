# syntax=docker/dockerfile:1.4
# ================================
# Build image
# ================================
ARG BUILDER_IMAGE=swift:6.3
# assay links the Swift stdlib statically, so a plain Ubuntu matching the builder's base is enough.
ARG RUNTIME_IMAGE=ubuntu:24.04

# Builder image
FROM ${BUILDER_IMAGE} AS build

WORKDIR /build

COPY . /build

# -lcurl: SwiftLint pulls in FoundationNetworking, whose static library needs libcurl at link time
ARG SWIFT_FLAGS="-c release -Xswiftc -static-stdlib -Xlinker -lcurl"

# .build and SwiftPM's cache are multi-GB: keep them in cache mounts so they never become image
# layers (which `cache-to: type=gha,mode=max` would upload and fill the runner disk with).
# HTTP/1.1 avoids HTTP/2 stream cancels on flaky networks; the retries absorb transient clone failures.
RUN --mount=type=cache,target=/build/.build \
    --mount=type=cache,target=/root/.cache \
    git config --global http.version HTTP/1.1 && \
    for attempt in 1 2 3 4 5; do \
        swift package --package-path /build resolve && break; \
        [ "$attempt" = 5 ] && exit 1; \
        sleep 5; \
    done && \
    swift build --package-path /build $SWIFT_FLAGS --product assay && \
    BIN_PATH=$(swift build --package-path /build $SWIFT_FLAGS --show-bin-path) && \
    mkdir -p /runtime/usr/bin && \
    install -m 0755 "$BIN_PATH/assay" /runtime/usr/bin/assay && \
    find "$BIN_PATH" -maxdepth 1 -name "assay-cli_*.resources" -exec cp -r {} /runtime/usr/bin/ \;

# SwiftLint loads SourceKit at runtime, which links the compiler's swift-syntax libraries and a few
# Swift runtime libraries. Keep the toolchain layout so their $ORIGIN RUNPATHs still resolve.
RUN mkdir -p /runtime/usr/lib/swift/linux /runtime/usr/lib/swift/host/compiler && \
    cp /usr/lib/libsourcekitdInProc.so /runtime/usr/lib/ && \
    cp /usr/lib/swift/host/compiler/lib_CompilerSwift*.so /runtime/usr/lib/swift/host/compiler/ && \
    for lib in swiftCore swift_Concurrency swiftGlibc swift_Builtin_float dispatch BlocksRuntime; do \
        cp "/usr/lib/swift/linux/lib$lib.so" /runtime/usr/lib/swift/linux/; \
    done && \
    strip /runtime/usr/bin/assay && \
    find /runtime/usr/lib -name '*.so' -exec strip --strip-unneeded {} +

# ================================
# Run image
# ================================

FROM ${RUNTIME_IMAGE}

# libcurl/libxml2: Foundation (linked statically into assay) still loads them dynamically.
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends libcurl4t64 libxml2 ca-certificates tzdata git && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /runtime/ /

CMD ["assay"]
