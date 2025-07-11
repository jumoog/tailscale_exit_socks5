# Tailscale Exit SOCKS5

This project provides a SOCKS5 proxy that routes traffic through a Tailscale exit node. It allows you to use your Tailscale network as a secure proxy endpoint.

## Features

- SOCKS5 proxy server
- Routes all traffic through a specified Tailscale exit node
- Restrict allowed destination addresses using the `TS_SOCKS_ALLOWED_DESTINATION` environment variable

## Requirements

- [Tailscale](https://tailscale.com/) installed and authenticated
- Go (if building from source) or a compatible binary

## Usage

1. Start Tailscale and connect to your network.
2. Enable an exit node on your Tailscale network.
3. (Optional) Restrict allowed destinations by setting the environment variable `TS_SOCKS_ALLOWED_DESTINATION` to a regular expression matching allowed addresses.
4. Run the SOCKS5 proxy:

   ```sh
   go run main.go --exit-node <exit-node-ip> --listen <local-port>
   ```

   Replace `<exit-node-ip>` with the IP address of your Tailscale exit node and `<local-port>` with the port you want the proxy to listen on (e.g., 1080).

5. Configure your applications to use `localhost:<local-port>` as a SOCKS5 proxy.

## Configuration

- `--exit-node`: IP address of the Tailscale exit node.
- `--listen`: Local port to listen for SOCKS5 connections.
- `TS_SOCKS_ALLOWED_DESTINATION`: (optional) Regular expression to restrict allowed destination addresses. Only destinations matching this regex will be allowed.

## Example

Allow only destinations in the `192.168.1.*` subnet:

```sh
set TS_SOCKS_ALLOWED_DESTINATION=^192\.168\.1\.\d+$
go run main.go --exit-node 100.101.102.103 --listen 1080
```

## License

MIT License

## Disclaimer

This project is not affiliated with Tailscale Inc. Use at your own risk.
