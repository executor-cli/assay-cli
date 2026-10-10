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

# Fetch dependencies in their own layer: HTTP/1.1 avoids HTTP/2 stream cancels on flaky networks,
# and the retries keep a transient clone failure from failing the whole build.
RUN git config --global http.version HTTP/1.1 && \
    for attempt in 1 2 3 4 5; do \
        swift package --package-path /build resolve && break; \
        [ "$attempt" = 5 ] && exit 1; \
        sleep 5; \
    done

# Compile with optimizations
ARG SWIFT_FLAGS="-c release -Xswiftc -g -Xswiftc -static-stdlib"

# Build the assay binary
RUN swift build --package-path /build $SWIFT_FLAGS --product assay

# Copy the assay binary
RUN BIN_PATH=$(swift build --package-path /build $SWIFT_FLAGS --show-bin-path) && \
    mkdir -p /assay-binary && \
    cp $BIN_PATH/assay /assay-binary/assay && \
    chmod +x /assay-binary/assay

# Copy the resource bundles (Bundle.module resolves them next to the executable)
RUN BIN_PATH=$(swift build --package-path /build $SWIFT_FLAGS --show-bin-path) && \
    mkdir -p /assay-resources && \
    find $BIN_PATH -maxdepth 1 -name "assay-cli_*.resources" -exec cp -r {} /assay-resources/ \;

# Copy Swift toolchain libraries needed by SwiftLint at runtime (SourceKit and the compiler's swift-syntax)
RUN mkdir -p /assay-libs && \
    cp /usr/lib/libsourcekitdInProc.so /assay-libs/ && \
    cp /usr/lib/swift/linux/*.so /assay-libs/ && \
    cp /usr/lib/swift/host/compiler/*.so /assay-libs/ 2>/dev/null || true

# Clean up build artifacts to reduce layer size
RUN rm -rf /build/.build/*/ModuleCache \
           /build/.build/*/index \
           /root/.cache

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
