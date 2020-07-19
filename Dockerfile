# syntax = docker/dockerfile:1-experimental
## Separating the downloading of our dependencies from our build is a great improvement but each time we run the build, we are starting the compile from scratch. For small projects this might not be a problem but as your project gets bigger you will want to leverage Go’s compiler cache.
##To do this, you will need to use BuildKit’s Dockerfile frontend (https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/experimental.md). 


FROM --platform=${BUILDPLATFORM} golang:1.14.6-alpine AS base
WORKDIR /src
ENV CGO_ENABLED=0
COPY go.* .
RUN go mod download

FROM base AS build
ARG TARGETOS
ARG TARGETARCH
RUN --mount=target=. \
  --mount=type=cache,target=/root/.cache/go-build \
  GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/example .


FROM base AS unit-test
RUN --mount=target=. \
  --mount=type=cache,target=/root/.cache/go-build \
  go test -v .

FROM golangci/golangci-lint:v1.28.3-alpine AS lint-base 

FROM base AS lint
COPY --from=lint-base /usr/bin/golangci-lint /usr/bin/golangci-lint
RUN --mount=target=. \
  --mount=from=lint-base,src=/usr/bin/golangci-lint,target=/usr/bin/golangci-lint \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/root/.cache/golangci-lint \
  golangci-lint run --timeout 10m0s ./... 

#scratch
FROM scratch AS bin-unix
COPY --from=build /out/example /

#other envirobments
FROM bin-unix AS bin-linux
FROM bin-unix AS bin-darwin

FROM scratch AS bin-windows
COPY --from=build /out/example /example.exe

FROM bin-${TARGETOS} AS bin