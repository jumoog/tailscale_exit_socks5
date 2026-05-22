# Tailscale v1.98.3
FROM golang:1.26-alpine AS build-env
ARG VERSION=release-branch/1.98
WORKDIR /go/src
ENV GOFLAGS="-tags=ts_omit_aws,ts_omit_bird,ts_omit_tap,ts_omit_kube,ts_omit_logtail,ts_omit_usermetrics,ts_omit_clientupdate,ts_include_cli -buildvcs=false -trimpath"
RUN apk add --no-cache git
RUN git clone --depth=1 -b ${VERSION} https://github.com/tailscale/tailscale.git . && git checkout ${VERSION}
COPY . .
RUN git apply "add-option-for-allowed-destinations.patch"
RUN /go/src/build_dist.sh shellvars > shellvars
RUN go mod download
RUN source /go/src/shellvars && go build -ldflags "-X tailscale.com/version.longStamp=$VERSION_LONG -X tailscale.com/version.shortStamp=$VERSION_SHORT -w -s -buildid=" ./cmd/tailscaled
RUN source /go/src/shellvars && go build -ldflags "-X tailscale.com/version.longStamp=$VERSION_LONG -X tailscale.com/version.shortStamp=$VERSION_SHORT -w -s -buildid=" ./cmd/tailscale
RUN source /go/src/shellvars && go build -ldflags "-X tailscale.com/version.longStamp=$VERSION_LONG -X tailscale.com/version.shortStamp=$VERSION_SHORT -w -s -buildid=" ./cmd/containerboot

FROM alpine:3.22
RUN apk add --no-cache ca-certificates iptables iproute2 ip6tables
RUN ln -s /sbin/iptables-legacy /sbin/iptables
RUN ln -s /sbin/ip6tables-legacy /sbin/ip6tables

COPY --from=build-env /go/src/tailscale /usr/local/bin/
COPY --from=build-env /go/src/tailscaled /usr/local/bin/
COPY --from=build-env /go/src/containerboot /usr/local/bin/

CMD [ "/usr/local/bin/containerboot" ]
