
#build stage
FROM --platform=${BUILDPLATFORM} golang:1.14.3-alpine AS build
WORKDIR /go/src/go-docker-template
ENV CGO_ENABLED=0
COPY . .
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/example .

#scratch
FROM scratch AS bin
COPY --from=build /out/example /

#other envirobments
FROM bin-unix AS bin-linux
FROM bin-unix AS bin-darwin

FROM scratch AS bin-windows
COPY --from=build /out/example /example.exe

FROM bin-${TARGETOS} AS bin