The Puppet Agent
===
 * Overview
 * Runtime requirements
 * Building puppet-agent
 * Building puppet-agent for windows
 * Installer plugin for OSX 
 * License
 * Maintainers

Overview
---
The puppet agent is a collection of software that is required for puppet and
its dependencies to run. The full list of software and projects included in the
puppet agent can be found in the [project
definition](configs/projects/puppet-agent.rb). This repo is where the
puppet-agent [vanagon](http://github.com/puppetlabs/vanagon) configuration
lives. It is used to drive the building of puppet-agent packages for releases.

Runtime Requirements
---
The [Gemfile](Gemfile) specifies all of the needed ruby libraries to build a puppet-agent
package. Additionally, puppet-agent requires a VM to build within for each
desired package.

Building puppet-agent
---
If you wish to build puppet-agent yourself, it should be relatively easy. First
`bundle install`, followed by `bundle exec build puppet-agent <desired
platform> <vm hostname>`, where the platform is a platform supported by vanagon
and vm hostname is the hostname of a vm of the desired platform. The current
user must be able to ssh into that vm as root (vanagon has facilities to provide
an ssh key beyond what is listed in .ssh/config).

Building puppet-agent for windows
---
For the moment, windows is a special case. It can be built using a similar
pattern to other platforms. `ruby bin/build-windows.rb BUILD_TARGET=win-x86` is
the way to do this. The windows build assumes access to Puppet Labs' vm pooler
and does not currently accept a hostname override. VANAGON\_SSH\_KEY is
respected for ssh key overrides.

Installer plugin for OSX
---
The GUI installer for OSX includes a custom plugin that captures and sets information such
as the puppet master and certificate name for the client.  The source for this Xcode project
can be found [here](https://github.com/puppetlabs/puppet-agent-osx-installer-plugin).

License
---
Puppet agent is licensed under the [Apache-2.0](LICENSE) license.

Maintainers
---
The Release Engineering team at Puppet Labs

