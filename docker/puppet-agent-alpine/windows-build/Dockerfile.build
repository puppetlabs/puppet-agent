FROM alpine:3.8

RUN apk add --no-cache cmake boost-dev make curl git curl-dev ruby ruby-dev gcc g++ yaml-cpp-dev

RUN mkdir /workspace 
WORKDIR /workspace
RUN sed -i -e 's/sys\/poll/poll/' /usr/include/boost/asio/detail/socket_types.hpp

ENV CMAKE_SHARED_OPTIONS='-DCMAKE_PREFIX_PATH=/opt/puppetlabs/puppet -DCMAKE_INSTALL_PREFIX=/opt/puppetlabs/puppet -DCMAKE_INSTALL_RPATH=/opt/puppetlabs/puppet/lib -DCMAKE_VERBOSE_MAKEFILE=ON'

RUN git clone -b 1.5.x https://github.com/puppetlabs/leatherman && mkdir -p /workspace/leatherman/build
WORKDIR /workspace/leatherman/build
RUN cmake $CMAKE_SHARED_OPTIONS -DBOOST_STATIC=OFF ..; make ; make install

WORKDIR /workspace
RUN git clone -b 0.2.x https://github.com/puppetlabs/libwhereami && mkdir -p /workspace/libwhereami/build
WORKDIR /workspace/libwhereami/build
RUN cmake $CMAKE_SHARED_OPTIONS -DBOOST_STATIC=OFF ..; make ; make install

WORKDIR /workspace
RUN git clone -b 0.2.x https://github.com/puppetlabs/cpp-hocon && mkdir -p /workspace/cpp-hocon/build
WORKDIR /workspace/cpp-hocon/build
RUN cmake $CMAKE_SHARED_OPTIONS -DBOOST_STATIC=OFF ..; make ; make install

WORKDIR /workspace
RUN git clone -b 3.12.x https://github.com/puppetlabs/facter && mkdir -p /workspace/facter/build
WORKDIR /workspace/facter/build
RUN cmake $CMAKE_SHARED_OPTIONS -DRUBY_LIB_INSTALL=/usr/lib/ruby/vendor_ruby ..; make ; make install

WORKDIR /workspace
RUN git clone -b 1.6.x https://github.com/puppetlabs/cpp-pcp-client && mkdir -p /workspace/cpp-pcp-client/build
WORKDIR /workspace/cpp-pcp-client/build
RUN cmake .. $CMAKE_SHARED_OPTIONS; make ; make install

WORKDIR /workspace
RUN git clone -b 1.10.x https://github.com/puppetlabs/pxp-agent && mkdir -p /workspace/pxp-agent/build
WORKDIR /workspace/pxp-agent/build
RUN cmake .. $CMAKE_SHARED_OPTIONS; make ; make install

RUN apk add --no-cache augeas ruby-augeas libressl-dev
RUN gem install --no-rdoc --no-ri deep_merge json etc semantic_puppet puppet-resource_api multi_json locale httpclient fast_gettext

WORKDIR /workspace
RUN curl -O -L https://people.redhat.com/~rjones/virt-what/files/virt-what-1.18.tar.gz && \
    tar zxf virt-what-1.18.tar.gz

WORKDIR /workspace/virt-what-1.18
RUN ./configure && \
    make && \
    make install

WORKDIR /workspace
RUN git clone -b 3.4.x https://github.com/puppetlabs/hiera
WORKDIR /workspace/hiera
RUN ./install.rb --no-configs --bindir=/opt/puppetlabs/puppet/bin --sitelibdir=/usr/lib/ruby/vendor_ruby

WORKDIR /workspace
RUN git clone -b 6.0.x https://github.com/puppetlabs/puppet
WORKDIR /workspace/puppet
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
