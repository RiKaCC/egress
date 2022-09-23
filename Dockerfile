FROM golang:1.18-alpine as builder

ARG TARGETPLATFORM
ARG TARGETARCH
RUN echo building for "$TARGETPLATFORM"

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
#RUN go mod download

# Copy the go source
COPY cmd/ cmd/
COPY pkg/ pkg/
COPY test/ test/
COPY version/ version/
COPY template-default/ template-default/
COPY template-sdk/ template-sdk/
COPY vendor/ vendor/

RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH GO111MODULE=on go build -a -o egress ./cmd/server

FROM alpine

COPY --from=builder /workspace/egress /egress

# Run the binary.
ENTRYPOINT ["/egress"]
