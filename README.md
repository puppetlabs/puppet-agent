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
its dependencies to run. This includes
[puppet](https://github.com/puppetlabs/puppet),
[facter](https://github.com/puppetlabs/facter), and other Puppet software, but
also vendored dependencies like ruby, curl, openssl, and more.

This repository contains configuration to build puppet-agent and the facter gem
for all of Puppet's supported platforms using
[vanagon](https://github.com/puppetlabs/vanagon), a packaging utiltiy.

The full list of software components built into the puppet agent and the
facter gem can be found in their [project definitions](configs/projects/), and
each of the components has its own configuration in the [components
directory](configs/components/).

Components that are not developed by Puppet (like ruby, curl, or openssl) are
built separately into a tarball and consumed here in the
[puppet-runtime](configs/components/puppet-runtime.rb) component. See the
[puppet-runtime](https://github.com/puppetlabs/puppet-runtime) project for more
information and a full list of the vendored dependencies it provides.

Runtime Requirements
---
Ruby and [bundler](http://bundler.io/) are required to build puppet-agent. The
[Gemfile](Gemfile) specifies all of the necessary ruby libraries to build a
puppet-agent package.  Additionally, puppet-agent requires a VM to build within
for each desired package.

## Environment variables
#### VANAGON\_LOCATION
The location of Vanagon in the Gemfile can be overridden with the environment variable `VANAGON_LOCATION`. Can be set prior to `bundle install` or updated with `bundle update`.

* `0.3.14` - Specific tag from the Vanagon git repo
* `git@github.com:puppetlabs/vanagon#master` - Remote git location and tag
* `file:///workspace/vanagon` - Absolute file path
* `file://../vanagon` - File path relative to the project directory

Building puppet-agent or the facter gem
---

If you wish to build puppet-agent or the facter gem yourself:

1. First, build the
   [puppet-runtime](https://github.com/puppetlabs/puppet-runtime) for your
   target platform and agent version.
2. Run `bundle install` to install required ruby dependencies.
3. When building puppet-agent or the cfacter gem on infrastructure outside of
   Puppet, you will need to make a few edits in the component and project
   files. The build process depends on the following packages:
     - GCC (>=4.8.0)
     - Boost (>=1.57)
     - CMake (>= 3.2.3)
     - yaml-cpp (>= 0.5.0)

     Any references to pl-gcc, pl-cmake, pl-boost, pl-yaml-cpp, etc. in the
     [configs directory](configs/) will need to be changed to refer to
     equivalent installable packages on your target operating system. In many
     cases, you can drop the `pl-` prefix and ensure that CXX or CC envrionment
     variables are what they should be.
4. Update the `location` and `version` in the [puppet-runtime
   component json file](configs/components/puppet-runtime.json) as follows:
   - `location` should be a file URL to your local puppet-runtime output
     directory, for example: `file:///home/you/puppet-runtime/output`
   - `version` should be the version of puppet-runtime that you built; You
     can find this value at the top level of the json metadata file produced by
     the build in your puppet-runtime output directory.
  - You also may need to change the source URIs for some other components. We
    recognize this is less than ideal at this point, but we wanted to err on
    the side of getting this work out in public rather than having everything
    perfect. If you have your own mirror of the components of puppet-agent, you
    can also use a rewrite rule. See the [Vanagon
    README](https://github.com/puppetlabs/vanagon/blob/master/examples/projects/project.rb#L26)
    for an example.
5. Now use vanagon to build the puppet-agent. Run the following:

   ```sh
   bundle exec build <project-name> <platform> <vm-hostname>
   ```

   Where:
   - project name is a project from [configs/projects](configs/projects) (this
     can be `puppet-agent`, `facter-gem`, or `facter-source-gem`),
   - platform is a platform supported by vanagon and defined in the
     [configs/platforms](configs/platforms/) directory (for example,
     `el-7-x86_64`), and
   - the vm hostname is the hostname of a vm matching the desired platform. The
     current user must be able to ssh into that vm as root (vanagon has facilities
     to provide an ssh key beyond what is listed in .ssh/config).

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
