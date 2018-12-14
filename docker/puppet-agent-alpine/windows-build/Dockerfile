FROM alpine:3.8

ARG version=6.0.0
ARG vcs_ref
ARG build_date

ENV PUPPET_AGENT_VERSION="$version"
ENV PATH="/opt/puppetlabs/bin:$PATH"

LABEL org.label-schema.maintainer="Puppet Release Team <release@puppet.com>" \
      org.label-schema.vendor="Puppet" \
      org.label-schema.url="https://github.com/puppetlabs/puppet-agent" \
      org.label-schema.name="Puppet Agent (Alpine)" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$PUPPET_AGENT_VERSION" \
      org.label-schema.vcs-url="https://github.com/puppetlabs/puppet-agent" \
      org.label-schema.vcs-ref="$vcs_ref" \
      org.label-schema.build-date="$build_date" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.dockerfile="/Dockerfile"

RUN apk add --no-cache \
    bash \
    ruby \
    curl \
    shadow \
    yaml-cpp \
    ruby-json \
    ruby-augeas \
    boost-random \
    boost-iostreams \
    boost-graph \
    boost-signals \
    boost \
    boost-serialization \
    boost-program_options \
    boost-system \
    boost-unit_test_framework \
    boost-math \
    boost-doc \
    boost-wserialization \
    boost-date_time \
    boost-wave \
    boost-filesystem \
    boost-prg_exec_monitor \
    boost-regex \
    boost-thread

COPY output/vendor_ruby /usr/lib/ruby/vendor_ruby/
COPY output/opt_puppetlabs /opt/puppetlabs/
COPY output/etc_puppetlabs /etc/puppetlabs/
COPY output/gems /usr/lib/ruby/gems/

ENTRYPOINT ["/opt/puppetlabs/bin/puppet"]
CMD ["agent", "--verbose", "--onetime", "--no-daemonize", "--summarize"]

COPY Dockerfile /
