# Create a stage for building the application.
ARG GO_VERSION=1.25-bookworm
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION} AS build

# Set the working directory in the container.
WORKDIR /src

# Download dependencies as a separate step to take advantage of Docker's caching.
RUN --mount=type=cache,target=/go/pkg/mod/ \
  --mount=type=bind,source=go.sum,target=go.sum \
  --mount=type=bind,source=go.mod,target=go.mod \
  go mod download -x

# This is the architecture you're building for, which is passed in by the builder.
# Placing it here allows the previous steps to be cached across architectures.
ARG TARGETARCH

# Build the application.
RUN --mount=type=cache,target=/go/pkg/mod/ \
  --mount=type=bind,target=. \
  CGO_ENABLED=0 GOARCH=$TARGETARCH \
  GOEXPERIMENT=jsonv2 \
  go build -trimpath --ldflags '-w -s -extldflags "-static"' -tags netgo -o /bin/server .

################################################################################
# Create a new stage for running the application that contains the minimal
# runtime dependencies for the application.
FROM alpine:3.22 AS final

# Install any runtime dependencies that are needed to run your application.
RUN --mount=type=cache,target=/var/cache/apk \
  apk --update add \
  ca-certificates \
  tzdata \
  && \
  update-ca-certificates

# # Create a non-privileged user that the app will run under.
# # See https://docs.docker.com/go/dockerfile-user-best-practices/
# ARG UID=10001
# RUN adduser \
#     --disabled-password \
#     --gecos "" \
#     --home "/nonexistent" \
#     --shell "/sbin/nologin" \
#     --no-create-home \
#     --uid "${UID}" \
#     appuser
# USER appuser

# Copy the pre-built executable from the "build" stage.
COPY --from=build /bin/server /bin/

# Expose the port that the application listens on.
EXPOSE 25222

# What the container should run when it is started.
ENTRYPOINT [ "/bin/server" ]