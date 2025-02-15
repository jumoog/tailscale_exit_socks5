# Tailscale v1.80.2
FROM golang:1.23-alpine AS build-env
ARG VERSION=release-branch/1.80
WORKDIR /go/src
ENV GOFLAGS="-tags=ts_omit_aws,ts_omit_bird,ts_omit_tap,ts_omit_kube,ts_include_cli -buildvcs=false -trimpath"
RUN apk add --no-cache git
RUN git clone --depth=1 -b ${VERSION} https://github.com/tailscale/tailscale.git . && git checkout ${VERSION}
COPY . .
RUN git apply "1-change-default-disable-remote-updates-and-log-upload.patch"
RUN git apply "2-add-option-for-allowed-destinations.patch"
RUN /go/src/build_dist.sh shellvars > shellvars
RUN go mod download
RUN source /go/src/shellvars && go build -ldflags "-X tailscale.com/version.longStamp=$VERSION_LONG -X tailscale.com/version.shortStamp=$VERSION_SHORT -w -s -buildid=" ./cmd/tailscaled
RUN source /go/src/shellvars && go build -ldflags "-X tailscale.com/version.longStamp=$VERSION_LONG -X tailscale.com/version.shortStamp=$VERSION_SHORT -w -s -buildid=" ./cmd/tailscale
RUN source /go/src/shellvars && go build -ldflags "-X tailscale.com/version.longStamp=$VERSION_LONG -X tailscale.com/version.shortStamp=$VERSION_SHORT -w -s -buildid=" ./cmd/containerboot

FROM alpine:3.18
RUN apk add --no-cache ca-certificates iptables iproute2 ip6tables

COPY --from=build-env /go/src/tailscale /usr/local/bin/
COPY --from=build-env /go/src/tailscaled /usr/local/bin/
COPY --from=build-env /go/src/containerboot /usr/local/bin/

CMD [ "/usr/local/bin/containerboot" ]
