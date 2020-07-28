# see hooks/build and hooks/.config
ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}alpine:latest

# see hooks/post_checkout
ARG QEMU_ARCH
COPY qemu-${QEMU_ARCH}-static /usr/bin

# update
RUN apk -U upgrade
RUN apk --no-cache add \
  dnsmasq \
  supervisor \
  tzdata

RUN cp /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
  echo "Europe/Paris" > /etc/timezone

RUN apk del tzdata \
  && rm -rf /var/cache/apk/*

ARG DG_ARCH
ARG DG_VERS=0.7.5

RUN wget https://github.com/Jeremie-C/my-docker-gen/releases/download/$DG_VERS/docker-gen-alpine-linux-$DG_ARCH-$DG_VERS.tar.gz -q \
    && tar -C /usr/local/bin -xvzf docker-gen-alpine-linux-$DG_ARCH-$DG_VERS.tar.gz \
    && rm docker-gen-alpine-linux-$DG_ARCH-$DG_VERS.tar.gz

RUN mkdir -p /etc/dnsmasq.d && \
	rm -f /etc/dnsmasq.conf && \
  rm -f /etc/supervisord.conf

COPY fichiers/dnsmasq.conf /etc/dnsmasq.conf
COPY fichiers/dnsmasq.tmpl /etc/dnsmasq.d/dockergen.tpl
COPY fichiers/supervisord.conf /etc/supervisord.conf

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod a+rwx,o-w /usr/local/bin/docker-entrypoint.sh

COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod a+rwx,o-w /usr/local/bin/healthcheck.sh

ENV HOST_NAME 'docker.local'
ENV HOST_IP '192.168.1.1'
ENV HOST_TLD 'local'
ENV DNS_NORESOLV false
ENV DNS_NOHOSTS false
ENV LOG_QUERIES false
ENV DOCKER_HOST unix:///var/run/docker.sock

EXPOSE 53/udp

VOLUME /etc/dnsmasq.d

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["supervisord"]

HEALTHCHECK --interval=5s --timeout=1s --retries=3 CMD ["healthcheck.sh"]

# Labels
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

LABEL maintainer="Jeremie-C <Jeremie-C@users.noreply.github.com>" \
  Description="Generate dnsmasq entry for local container - image based on my-docker-gen" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.name="my-dnsmasq-gen" \
  org.label-schema.description="Generate dnsmasq entry for local container - image based on my-docker-gen" \
  org.label-schema.url="https://github.com/Jeremie-C/my-dnsmasq-gen" \
  org.label-schema.usage="https://github.com/Jeremie-C/my-dnsmasq-gen/tree/master/README.md" \
  org.label-schema.vcs-url="https://github.com/Jeremie-C/my-dnsmasq-gen" \
  org.label-schema.vcs-ref="${BUILD_REF}" \
  org.label-schema.version="${BUILD_VERSION}"
