######################################################
# build tooling
######################################################
ARG alpine_version=3.9

FROM alpine:${alpine_version} as build

# note: JAVA_HOME cannot be defined in the same ENV block it's used in
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV PATH=$PATH:$JAVA_HOME/jre/bin:$JAVA_HOME/bin \
    CMAKE_SHARED_OPTIONS='-DCMAKE_PREFIX_PATH=/opt/puppetlabs/puppet -DCMAKE_INSTALL_PREFIX=/opt/puppetlabs/puppet -DCMAKE_INSTALL_RPATH=/opt/puppetlabs/puppet/lib -DCMAKE_VERBOSE_MAKEFILE=ON -Bbuild'

# pin back to boost, gcc and g++ packages from alpine 3.8
# 3.9+ packages g++6 and gcc6 are difficult to install, even when using --force-broken-world
# hadolint ignore=DL3018,DL3028
RUN apk add --no-cache --update-cache --repository http://nl.alpinelinux.org/alpine/v3.8/main cmake boost-dev make gcc=6.4.0-r9 g++=6.4.0-r9  && \
    apk add --no-cache cmake boost-dev make curl git curl-dev ruby ruby-dev yaml-cpp-dev jq openjdk8 augeas ruby-augeas ruby-etc ruby-json ruby-multi_json libressl-dev virt-what && \
    gem install --no-rdoc --no-ri deep_merge semantic_puppet puppet-resource_api locale httpclient fast_gettext concurrent-ruby

RUN mkdir /workspace && \
    sed -i -e 's/sys\/poll/poll/' /usr/include/boost/asio/detail/socket_types.hpp

######################################################
# leatherman (build from source)
######################################################

FROM build as leatherman
WORKDIR /workspace/leatherman

COPY configs/components/leatherman.json /workspace
RUN git clone -b master https://github.com/puppetlabs/leatherman . && \
    git checkout "$(jq -r .ref /workspace/leatherman.json)" && \
    cmake . -DBOOST_STATIC=OFF -DCMAKE_VERBOSE_MAKEFILE=ON -Bbuild; make -C build ; make -C build install

######################################################
# libwhereami (build from source)
#   depends on leatherman
######################################################

FROM leatherman as libwhereami
WORKDIR /workspace/libwhereami

COPY configs/components/libwhereami.json /workspace
# hadolint ignore=SC2086
RUN git clone https://github.com/puppetlabs/libwhereami . && \
    git checkout "$(jq -r .ref /workspace/libwhereami.json)" && \
    cmake $CMAKE_SHARED_OPTIONS -DBOOST_STATIC=OFF .; make -C build ; make -C build install

######################################################
# cpp-hocon (build from source)
#   depends on leatherman
######################################################

FROM leatherman as cpp-hocon
WORKDIR /workspace/cpp-hocon

COPY configs/components/cpp-hocon.json /workspace
# hadolint ignore=SC2086
RUN git clone https://github.com/puppetlabs/cpp-hocon . && \
    git checkout "$(jq -r .ref /workspace/cpp-hocon.json)" && \
    cmake $CMAKE_SHARED_OPTIONS -DBOOST_STATIC=OFF .; make -C build ; make -C build install

######################################################
# pxp-agent (build from source)
#   depends on cpp-hocon -> leatherman (file COPY)
#   builds cpp-pcp-client
######################################################

FROM leatherman as pxp-agent
WORKDIR /workspace/cpp-pcp-client

COPY configs/components/cpp-pcp-client.json /workspace
# hadolint ignore=SC2086
RUN git clone https://github.com/puppetlabs/cpp-pcp-client . && \
    git checkout "$(jq -r .ref /workspace/cpp-pcp-client.json)" && \
    cmake . $CMAKE_SHARED_OPTIONS; make -C build ; make -C build install

# wait for cpp-hocon to compile to /opt/puppetlabs/puppet/lib/libcpp-hocon.a
COPY --from=cpp-hocon /opt/puppetlabs /opt/puppetlabs

WORKDIR /workspace/pxp-agent

COPY configs/components/pxp-agent.json /workspace
# hadolint ignore=SC2086
RUN git clone https://github.com/puppetlabs/pxp-agent . && \
    git checkout "$(jq -r .ref /workspace/pxp-agent.json)" && \
    cmake . $CMAKE_SHARED_OPTIONS; make -C build ; make -C build install

######################################################
# puppet (install from source)
#   installs hiera, facter
######################################################

FROM build as puppet

WORKDIR /workspace/hiera

COPY configs/components/hiera.json /workspace
RUN git clone https://github.com/puppetlabs/hiera . && \
    git checkout "$(jq -r .ref /workspace/hiera.json)" && \
    ./install.rb --no-configs --bindir=/opt/puppetlabs/puppet/bin --sitelibdir=/usr/lib/ruby/vendor_ruby

WORKDIR /workspace/facter

COPY configs/components/facter.json /workspace
# hadolint ignore=DL3028
RUN git clone https://github.com/puppetlabs/facter . && \
    git checkout "$(jq -r .ref /workspace/facter.json)" && gem build facter.gemspec && \
    gem install --no-rdoc --no-ri facter-*.gem --bindir /opt/puppetlabs/puppet/bin

WORKDIR /workspace/puppet

COPY configs/components/puppet.json /workspace
RUN git clone https://github.com/puppetlabs/puppet . && \
    git checkout "$(jq -r .ref /workspace/puppet.json)" && \
    ./install.rb --bindir=/opt/puppetlabs/puppet/bin --configdir=/etc/puppetlabs/puppet --sitelibdir=/usr/lib/ruby/vendor_ruby --codedir=/etc/puppetlabs/code --vardir=/opt/puppetlabs/puppet/cache --logdir=/var/log/puppetlabs/puppet --rundir=/var/run/puppetlabs --quick

RUN mkdir -p /opt/puppetlabs/bin && \
    ln -s /opt/puppetlabs/puppet/bin/facter /opt/puppetlabs/bin/facter && \
    ln -s /opt/puppetlabs/puppet/bin/puppet /opt/puppetlabs/bin/puppet && \
    ln -s /opt/puppetlabs/puppet/bin/hiera /opt/puppetlabs/bin/hiera

ENV PATH="/opt/puppetlabs/bin:$PATH"

RUN puppet config set confdir /etc/puppetlabs/puppet && \
    puppet config set codedir /etc/puppetlabs/code && \
    puppet config set vardir /opt/puppetlabs/puppet/cache && \
    puppet config set logdir /var/log/puppetlabs/puppet && \
    puppet config set rundir /var/run/puppetlabs && \
    mkdir -p /etc/puppetlabs/code/environment/production && \
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

######################################################
# final (assemble prior stages)
#   depends on puppet -> hiera
#   depends on pxp-agent -> cpp-hocon -> leatherman (file COPY)
#                           cpp-pcp-client
######################################################

FROM alpine:3.9 as final

ARG version=6.0.0
ARG vcs_ref
ARG build_date

ENV PATH="/opt/puppetlabs/bin:$PATH"

ENTRYPOINT ["/opt/puppetlabs/bin/puppet"]
CMD ["agent", "--verbose", "--onetime", "--no-daemonize", "--summarize"]

LABEL org.label-schema.maintainer="Puppet Release Team <release@puppet.com>" \
      org.label-schema.vendor="Puppet" \
      org.label-schema.url="https://github.com/puppetlabs/puppet-agent" \
      org.label-schema.name="Puppet Agent (Alpine)" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.vcs-url="https://github.com/puppetlabs/puppet-agent" \
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
    ruby-etc \
    ruby-json \
    ruby-multi_json \
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
    boost-thread \
    virt-what

COPY --from=pxp-agent /opt/puppetlabs /opt/puppetlabs
COPY --from=puppet /etc/puppetlabs /etc/puppetlabs
COPY --from=puppet /opt/puppetlabs /opt/puppetlabs
COPY --from=puppet /usr/lib/ruby/gems /usr/lib/ruby/gems
COPY --from=puppet /usr/lib/ruby/vendor_ruby /usr/lib/ruby/vendor_ruby

LABEL org.label-schema.vcs-ref="$vcs_ref" \
      org.label-schema.version="$version" \
      org.label-schema.build-date="$build_date"

COPY docker/puppet-agent-alpine/Dockerfile /
