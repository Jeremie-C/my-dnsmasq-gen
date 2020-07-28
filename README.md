# My-Dnsmasq-Gen
=====

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Jeremie-C/my-dnsmasq-gen)
![docker build](https://img.shields.io/docker/cloud/build/jeremiec82/my-dnsmasq-gen)
![docker pull](https://img.shields.io/docker/pulls/jeremiec82/my-dnsmasq-gen)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)

Container running Dnsmasq, Supervisord and my-docker-gen.

## Supported Architectures

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |
| armv7 | arm32v7-latest |
| armv6 | arm32v6-latest |

## Usage

```
docker create \
  --name=dnsmasq-gen \
  --cap-add=NET_ADMIN \
  -p 53:53/udp \
  -e HOST_NAME=docker.local \
  -e HOST_IP=192.168.1.1 \
  -e HOST_TLD=local `#optional` \
  -e DNS_NORESOLV=false  `#optional` \
  -e DNS_NOHOSTS=false  `#optional` \
  -e LOG_QUERIES=false  `#optional` \
  -v /path/to/dnsmasq.d:/etc/dnsmasq.d \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  jeremiec82/my-dnsmasq-gen
```

## Parameters

| Parameter | Function |
| :----: | --- |
| `-p 53/udp` | dnsmasq port |
| `-e HOST_NAME=docker.local` | Hostname for docker host inserted in dnsmasq |
| `-e HOST_IP=192.168.1.1` | External IP for docker host inserted in dnsmasq |
| `-e HOST_TLD=local` | Extension for containers EG nginx.local |
| `-e DNS_NORESOLV=false` | If true, dnsmasq don't use container resolv.conf  |
| `-e DNS_NOHOSTS=false` | If true, dnsmasq don't use container /etc/hosts file |
| `-e LOG_QUERIES=false` | If true, all queries are logged |
| `-v /etc/dnsmasq.d` | Contains all relevant configuration files. |
| `-v /var/run/docker.sock:ro` | my-docker-gen source for new containers configuration. |

## How it works

When a new container is started, stopped, ... my-docker-gen is informed and create the container in dnsmasq.

_Example:_
You create a container named "nginx", you can access it with nginx.local

## Assign domain name to a container

If you want to access a container with a full url like 'nginx.demo.in' you have to set "DNS_NAME" environnent variable.

_Example:_
```
docker create \
  --name=nginx-web \
  -e DNS_NAME=nginx.demo.in \
  -v /some/content:/usr/share/nginx/html:ro \
  nginx
```
