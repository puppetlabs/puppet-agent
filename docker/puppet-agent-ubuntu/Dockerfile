FROM ubuntu:18.04

ARG version="6.0.0"
ARG vcs_ref
ARG build_date
ARG UBUNTU_CODENAME="bionic"

LABEL org.label-schema.maintainer="Puppet Release Team <release@puppet.com>" \
      org.label-schema.vendor="Puppet" \
      org.label-schema.url="https://github.com/puppetlabs/puppet-agent" \
      org.label-schema.name="Puppet Agent (Ubuntu)" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.vcs-url="https://github.com/puppetlabs/puppet-agent" \
      org.label-schema.version=$version \
      org.label-schema.vcs-ref="$vcs_ref" \
      org.label-schema.build-date="$build_date" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.dockerfile="/Dockerfile"

ADD https://apt.puppetlabs.com/puppet6-release-"$UBUNTU_CODENAME".deb /puppet6.deb

# hadolint ignore=DL3008
RUN dpkg -i /puppet6.deb && \
    rm /puppet6.deb && \
    apt-get update && \
    apt-get install --no-install-recommends -y ca-certificates lsb-release puppet-agent="$version"-1"$UBUNTU_CODENAME" && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

ENTRYPOINT ["/opt/puppetlabs/bin/puppet"]
CMD ["agent", "--verbose", "--onetime", "--no-daemonize", "--summarize"]

COPY Dockerfile /
