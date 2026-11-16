# syntax=docker/dockerfile:1.4
# ================================
# Build image
# ================================
ARG BUILDER_IMAGE=swift:6.3
ARG RUNTIME_IMAGE=swift:6.3-slim

# Builder image
FROM ${BUILDER_IMAGE} AS build

WORKDIR /build

COPY . /build

# -lcurl: SwiftLint pulls in FoundationNetworking, whose static library needs libcurl at link time
ARG SWIFT_FLAGS="-c release -Xswiftc -g -Xswiftc -static-stdlib -Xlinker -lcurl"

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
    mkdir -p /assay-binary /assay-resources && \
    install -m 0755 "$BIN_PATH/assay" /assay-binary/assay && \
    find "$BIN_PATH" -maxdepth 1 -name "assay-cli_*.resources" -exec cp -r {} /assay-resources/ \;

# Copy Swift toolchain libraries needed by SwiftLint at runtime (SourceKit and the compiler's swift-syntax)
RUN mkdir -p /assay-libs && \
    cp /usr/lib/libsourcekitdInProc.so /assay-libs/ && \
    cp /usr/lib/swift/linux/*.so /assay-libs/ && \
    cp /usr/lib/swift/host/compiler/*.so /assay-libs/ 2>/dev/null || true

# ================================
# Run image
# ================================

FROM ${RUNTIME_IMAGE}

# Copy the executable, resource bundles, and shared libraries
COPY --from=build /assay-binary/assay /usr/bin/assay
COPY --from=build /assay-resources /usr/bin/
COPY --from=build /assay-libs/* /usr/lib/

# Set entrypoint
CMD ["assay"]
