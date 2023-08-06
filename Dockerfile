# syntax=docker/dockerfile:1
#FROM golang:1.20-alpine
#FROM golang:1.20-alpine AS base
ARG GO_VERSION=1.20
ARG GOLANGCI_LINT_VERSION=v1.52
FROM golang:${GO_VERSION}-alpine AS base
WORKDIR /src
#COPY go.mod go.sum .
#RUN go mod download
RUN --mount=type=cache,target=/go/pkg/mod/        \
    --mount=type=bind,source=go.mod,target=go.mod \
    --mount=type=bind,source=go.sum,target=go.sum \ 
    go mod download -x
#COPY . .

FROM base AS build_client
#RUN go build -o /bin/client ./cmd/client
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,target=.             \
    go build -o /bin/client ./cmd/client

FROM base AS build_server
ARG APP_VERSION="v0.0.0+unkown"
#RUN go build -o /bin/server ./cmd/server
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,target=.            \
    #go build -o /bin/server ./cmd/server
    go build -ldflags "-X main.version=$APP_VERSION" -o /bin/server ./cmd/server

#FROM scratch
#COPY --from=0 /bin/client /bin/server /bin/

FROM scratch AS client
COPY --from=build_client /bin/client /bin/
ENTRYPOINT [ "/bin/client" ]

FROM scratch AS server
COPY --from=build_server /bin/server /bin/
ENTRYPOINT [ "/bin/server" ]

FROM scratch AS binaries
COPY --from=build_client /bin/client /
COPY --from=build_server /bin/server /

FROM golangci/golangci-lint:${GOLANGCI_LINT_VERSION} AS lint
WORKDIR ./test
RUN --mount=type=bind,target=. \
    golangci-lint run

FROM scratch AS doc-lint
COPY --from=lint ./test /
