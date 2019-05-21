FROM madharjan/docker-base:16.04
MAINTAINER Madhav Raj Maharjan <madhav.maharjan@gmail.com>

ARG VCS_REF
ARG TEMPLATE_VERSION
ARG DEBUG=false

LABEL description="Docker container for Template Server" os_version="Ubuntu ${UBUNTU_VERSION}" \
      org.label-schema.vcs-ref=${VCS_REF} org.label-schema.vcs-url="https://github.com/madharjan/docker-template"

ENV TEMPLATE_VERSION ${TEMPLATE_VERSION}

RUN mkdir -p /build
COPY . /build

RUN chmod 755 /build/scripts/*.sh && /build/scripts/install.sh && /build/scripts/cleanup.sh

VOLUME ["/etc/template/data", "/var/log/template"]

CMD ["/sbin/my_init"]

EXPOSE 1234
