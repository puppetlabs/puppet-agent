The Puppet Agent
===
 * Overview
 * Runtime requirements
 * Building puppet-agent
 * Branches in puppet-agent
 * Installer plugin for OSX
 * License
 * Maintainers
 * Running Tests

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

## Environment variables
#### VANAGON\_LOCATION
The location of Vanagon in the Gemfile can be overridden with the environment variable `VANAGON_LOCATION`. Can be set prior to `bundle install` or updated with `bundle update`.

* `0.3.14` - Specific tag from the Vanagon git repo
* `git@github.com:puppetlabs/vanagon#master` - Remote git location and tag
* `file:///workspace/vanagon` - Absolute file path
* `file://../vanagon` - File path relative to the project directory

Building puppet-agent
---
If you wish to build puppet-agent yourself, it should be relatively easy. First
`bundle install`, followed by `bundle exec build puppet-agent <desired
platform> <vm hostname>`, where the platform is a platform supported by vanagon
and vm hostname is the hostname of a vm of the desired platform. The current
user must be able to ssh into that vm as root (vanagon has facilities to provide
an ssh key beyond what is listed in .ssh/config).

#### Building different ruby versions
There are multiple ruby versions available to use in puppet-agent. To switch between ruby versions, update the `ruby_version` and `gem_home` settings in the [puppet-agent project config](https://github.com/puppetlabs/puppet-agent/blob/master/configs/projects/puppet-agent.rb)

To switch to ruby 2.3.3:

  ```
  proj.setting(:ruby_version, "2.3.3")`
  proj.setting(:gem_home, File.join(proj.libdir, "ruby", "gems", "2.3.0"))
  ```

To switch to ruby 2.1.9:

  ```
  proj.setting(:ruby_version, "2.1.9")`
  proj.setting(:gem_home, File.join(proj.libdir, "ruby", "gems", "2.1.0"))
  ```



Requirements for building
---
To build puppet-agent, you'll need the following:
 * GCC (>=4.8.0)
 * Boost (>=1.57)
 * CMake (>= 3.2.3)
 * yaml-cpp (>= 0.5.0)

To build puppet-agent on infrastructure outside of Puppet Labs, you'll need to make a few edits in the component and project files. Any references to pl-gcc, pl-cmake, pl-boost, pl-yaml-cpp, etc need to be changed. In many cases, just drop the pl- prefix and ensure that CXX or CC envrionment variables are what they should be.

You also may need to change the source URIs for components. We recognize this is less than ideal at this point, but we wanted to error on the side of getting this work out in public rather than having everything perfect.

If you have your own mirror of the components of puppet-agent, you can also use a rewrite rule. See the [Vanagon README](https://github.com/puppetlabs/vanagon/blob/master/examples/projects/project.rb#L26) for an example.

Branches in puppet-agent
---

Tracking branch (master + stable):
  * some components may reference tags if they’re slow moving (ruby, openssl)
  * some components reference SHAs promoted by a CI pipeline (generally puppet-agent#master pipelines track components' master branches, and likewise for stable)

Guidelines on Merging Between Branches
* stable should be merged to master regularly (e.g. per commit), as is done for component repos; no PR needed
* master should be merged to stable as-needed; typically this is done when a component merges its master to stable, and there are matching changes needed in puppet-agent

Generally, no PR is needed for routine merges from stable to master, but a PR is advised for other merges. Use your judgment of course, and put up a PR if you want review.

Note that for all merges from master or stable, the merge should pick up:
* changes outside of config/components
* changes that bumped to a tag inside config/components

But never:
* changes that bumped to a SHA inside config/components

Here's a sample snippet used for a stable -> master merge:

```
git merge --no-commit --no-ff stable
for i in {hiera,facter,puppet,marionette-collective,pxp-agent,cpp-pcp-client}; do git checkout master -- configs/components/$i.json;done
git checkout master -- configs/components/windows_puppet.json
git commit -m "(maint) Restore promoted components refs after merge from stable"
```

Installer plugin for OSX
---
The GUI installer for OSX includes a custom plugin that captures and sets information such
as the puppet master and certificate name for the client.  The source for this Xcode project
can be found [here](https://github.com/puppetlabs/puppet-agent-osx-installer-plugin).

Issues
---
File issues in the [Puppet Agent (PA) project](https://tickets.puppet.com/browse/PA) on the Puppet Labs Jira site. Issues with individual components should be filed in their respective projects.

License
---
Puppet agent is licensed under the [Apache-2.0](LICENSE) license.

Maintainers
---
See [MAINTAINERS](MAINTAINERS)

Running Tests
---
See [Acceptance README](acceptance/README)
