FROM alpine:3.8 as build

# hadolint ignore=DL3018
RUN apk add --no-cache cmake boost-dev make curl git curl-dev ruby ruby-dev gcc g++ yaml-cpp-dev jq openjdk8

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:$JAVA_HOME/jre/bin:$JAVA_HOME/bin

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN mkdir /workspace
WORKDIR /workspace
RUN sed -i -e 's/sys\/poll/poll/' /usr/include/boost/asio/detail/socket_types.hpp

COPY configs/components/leatherman.json /workspace
RUN git clone -b master https://github.com/puppetlabs/leatherman && \
    mkdir -p /workspace/leatherman/build
WORKDIR /workspace/leatherman/build
RUN git checkout "$(jq .ref /workspace/leatherman.json | tr -d \")" && \
    cmake .. -DBOOST_STATIC=OFF -DCMAKE_VERBOSE_MAKEFILE=ON ; make ; make install
ENV CMAKE_SHARED_OPTIONS='-DCMAKE_PREFIX_PATH=/opt/puppetlabs/puppet -DCMAKE_INSTALL_PREFIX=/opt/puppetlabs/puppet -DCMAKE_INSTALL_RPATH=/opt/puppetlabs/puppet/lib -DCMAKE_VERBOSE_MAKEFILE=ON'

WORKDIR /workspace

COPY configs/components/libwhereami.json /workspace
RUN git clone https://github.com/puppetlabs/libwhereami && \
    mkdir -p /workspace/libwhereami/build
WORKDIR /workspace/libwhereami/build
RUN git checkout "$(jq .ref /workspace/libwhereami.json | tr -d \")"
RUN cmake $CMAKE_SHARED_OPTIONS -DBOOST_STATIC=OFF ..; make ; make install

WORKDIR /workspace

COPY configs/components/cpp-hocon.json /workspace
RUN git clone https://github.com/puppetlabs/cpp-hocon && \
    mkdir -p /workspace/cpp-hocon/build
WORKDIR /workspace/cpp-hocon/build
RUN git checkout "$(jq .ref /workspace/cpp-hocon.json | tr -d \")"
RUN cmake $CMAKE_SHARED_OPTIONS -DBOOST_STATIC=OFF ..; make ; make install

WORKDIR /workspace

COPY configs/components/facter.json /workspace

RUN git clone https://github.com/puppetlabs/facter && \
    mkdir -p /workspace/facter/build
WORKDIR /workspace/facter/build
RUN git checkout "$(jq .ref /workspace/facter.json | tr -d \")"
RUN cmake /lib $CMAKE_SHARED_OPTIONS -DRUBY_LIB_INSTALL=/usr/lib/ruby/vendor_ruby ..; make ; make install

WORKDIR /workspace

COPY configs/components/cpp-pcp-client.json /workspace
RUN git clone https://github.com/puppetlabs/cpp-pcp-client && \
    mkdir -p /workspace/cpp-pcp-client/build
WORKDIR /workspace/cpp-pcp-client/build
RUN git checkout "$(jq .ref /workspace/cpp-pcp-client.json | tr -d \")"
RUN cmake .. $CMAKE_SHARED_OPTIONS ; make ; make install

WORKDIR /workspace

COPY configs/components/pxp-agent.json /workspace
RUN git clone https://github.com/puppetlabs/pxp-agent && \
    mkdir -p /workspace/pxp-agent/build
WORKDIR /workspace/pxp-agent/build
RUN git checkout "$(jq .ref /workspace/pxp-agent.json | tr -d \")"
RUN cmake .. $CMAKE_SHARED_OPTIONS ; make ; make install

# hadolint ignore=DL3018
RUN apk add --no-cache augeas ruby-augeas libressl-dev
# hadolint ignore=DL3028
RUN gem install --no-rdoc --no-ri deep_merge json etc semantic_puppet puppet-resource_api multi_json locale httpclient fast_gettext concurrent-ruby

WORKDIR /workspace
RUN curl -O -L https://people.redhat.com/~rjones/virt-what/files/virt-what-1.18.tar.gz && \
    tar zxf virt-what-1.18.tar.gz

WORKDIR /workspace/virt-what-1.18
RUN ./configure && \
    make && \
    make install

WORKDIR /workspace

COPY configs/components/hiera.json /workspace
RUN git clone https://github.com/puppetlabs/hiera
WORKDIR /workspace/hiera
RUN git checkout "$(jq .ref /workspace/hiera.json | tr -d \")"
RUN ./install.rb --no-configs --bindir=/opt/puppetlabs/puppet/bin --sitelibdir=/usr/lib/ruby/vendor_ruby

WORKDIR /workspace
COPY configs/components/puppet.json /workspace
RUN git clone https://github.com/puppetlabs/puppet
WORKDIR /workspace/puppet
RUN git checkout "$(jq .ref /workspace/puppet.json | tr -d \")"
RUN ./install.rb --bindir=/opt/puppetlabs/puppet/bin --configdir=/etc/puppetlabs/puppet --sitelibdir=/usr/lib/ruby/vendor_ruby --codedir=/etc/puppetlabs/code --vardir=/opt/puppetlabs/puppet/cache --logdir=/var/log/puppetlabs/puppet --rundir=/var/run/puppetlabs --quick

RUN mkdir -p /opt/puppetlabs/bin && \
    ln -s /opt/puppetlabs/puppet/bin/facter /opt/puppetlabs/bin/facter && \
    ln -s /opt/puppetlabs/puppet/bin/puppet /opt/puppetlabs/bin/puppet && \
    ln -s /opt/puppetlabs/puppet/bin/hiera /opt/puppetlabs/bin/hiera

ENV PATH="/opt/puppetlabs/bin:$PATH"

RUN puppet config set confdir /etc/puppetlabs/puppet && \
    puppet config set codedir /etc/puppetlabs/code && \
    puppet config set vardir /opt/puppetlabs/puppet/cache && \
    puppet config set logdir /var/log/puppetlabs/puppet && \
    puppet config set rundir /var/run/puppetlabs

RUN mkdir -p /etc/puppetlabs/code/environment/production && \
    puppet module install puppetlabs-augeas_core && \
    puppet module install puppetlabs-cron_core && \
    puppet module install puppetlabs-host_core && \
    puppet module install puppetlabs-mount_core && \
    puppet module install puppetlabs-scheduled_task && \
    puppet module install puppetlabs-selinux_core && \
    puppet module install puppetlabs-sshkeys_core && \
    puppet module install puppetlabs-yumrepo_core && \
    puppet module install puppetlabs-zfs_core && \
    puppet module install puppetlabs-zone_core && \
    puppet module install puppetlabs-apk


FROM alpine:3.8

ARG version=6.0.0
ARG vcs_ref
ARG build_date
ARG PUPPET_AGENT_VERSION="$version"

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

# hadolint ignore=DL3018
RUN apk add --no-cache \
    bash \
    ruby \
    bind-tools \
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

COPY --from=build /etc/puppetlabs /etc/puppetlabs
COPY --from=build /opt/puppetlabs /opt/puppetlabs
COPY --from=build /usr/lib/ruby/gems /usr/lib/ruby/gems
COPY --from=build /usr/lib/ruby/vendor_ruby /usr/lib/ruby/vendor_ruby

ENTRYPOINT ["/opt/puppetlabs/bin/puppet"]
CMD ["agent", "--verbose", "--onetime", "--no-daemonize", "--summarize"]

COPY docker/puppet-agent-alpine/Dockerfile /
