component 'puppet-runtime' do |pkg, settings, platform|
  # puppet-runtime (https://github.com/puppetlabs/puppet-runtime) is maintained
  # as a separate vanagon project. You must set $PUPPET_RUNTIME_PROJECT_PATH to
  # build puppet-agent outisde of puppetlabs infrastructure. See
  # configs/projects/puppet-agent.rb for build instructions.
  if ENV['PUPPET_RUNTIME_PROJECT_PATH']
    # Attempt to find a tarball in the `output/` directory of a local puppet-runtime clone
    project_path = File.expand_path(ENV['PUPPET_RUNTIME_PROJECT_PATH'])

    raise "Unable to find a puppet-runtime project directory at #{project_path}" unless Dir.exist?(project_path)

    output_path = File.join(project_path, 'output')
    raise "Unable to find an output/ directory in #{project_path}"\
          " -- Have you built puppet-runtime yet?"\
          unless Dir.exist?(output_path)

    # Set the component version based on `git describe` output
    git_describe = Dir.chdir(project_path) { %x(git describe) }.chomp
    raise "Unable to `git describe` the project at #{project_path}." if git_describe.empty?

    # Packages use the git-describe output as the version, but `-` is replaced with `.`
    pkg.version git_describe.tr('-', '.')

    # Construct the tarball name from the output path and component name and version
    tarball_name = "#{settings[:puppet_runtime_project]}-#{pkg.get_version}.#{platform.name}.tar.gz"
    tarball_path = File.join(output_path, tarball_name)
    sha1sum_path = File.join(output_path, "#{tarball_name}.sha1")

    raise "Unable to find a puppet-runtime tarball at '#{tarball_path}'"\
          " -- Have you built puppet-runtime for the '#{git_describe}' revision and the '#{platform.name}' platform yet?"\
          unless File.exist?(tarball_path)

    raise "Unable to find a sha1sum file for the puppet-runtime tarball at '#{sha1sum_path}'"\
          " -- Either rebuild puppet-runtime or ensure this file contains a sha1sum of #{tarball_path}"\
          unless File.exist?(sha1sum_path)

    pkg.url "file://#{tarball_path}"
    pkg.sha1sum sha1sum_path
  else
    # Assume this build is taking place on puppetlabs infrastructure
    runtime_details = JSON.parse(File.read('configs/components/puppet-runtime.json'))
    runtime_tag = runtime_details['ref'][/refs\/tags\/(.*)/, 1]
    raise "Unable to determine a tag for puppet-runtime (given #{runtime_details['ref']})" unless runtime_tag
    pkg.version runtime_tag

    tarball_name = "#{settings[:puppet_runtime_project]}-#{pkg.get_version}.#{platform.name}.tar.gz"

    pkg.sha1sum "http://builds.puppetlabs.lan/puppet-runtime/#{pkg.get_version}/artifacts/#{tarball_name}.sha1"
    pkg.url "http://builds.puppetlabs.lan/puppet-runtime/#{pkg.get_version}/artifacts/#{tarball_name}"
  end

  # The contents of the runtime replace the following:
  pkg.replaces 'pe-augeas'
  pkg.replaces 'pe-openssl'
  pkg.replaces 'pe-ruby'
  pkg.replaces 'pe-ruby-mysql'
  pkg.replaces 'pe-rubygems'
  pkg.replaces 'pe-libyaml'
  pkg.replaces 'pe-libldap'
  pkg.replaces 'pe-ruby-ldap'
  pkg.replaces 'pe-ruby-augeas'
  pkg.replaces 'pe-ruby-selinux'
  pkg.replaces 'pe-ruby-shadow'
  pkg.replaces 'pe-ruby-stomp'
  pkg.replaces 'pe-rubygem-deep-merge'
  pkg.replaces 'pe-rubygem-net-ssh'

  pkg.install_only true

  if platform.is_cross_compiled_linux? || platform.is_solaris? || platform.is_aix?
    pkg.build_requires 'runtime'
  end

  # Even though puppet's ruby comes from puppet-runtime, we still need a ruby
  # to build with on these platforms:
  if platform.architecture == "sparc"
    if platform.os_version == "11"
      pkg.build_requires 'pl-ruby'
    end
  elsif platform.is_cross_compiled_linux?
    pkg.build_requires 'pl-ruby'
  end

  if platform.is_windows?
    # Elevate.exe is simply used when one of the run_facter.bat or
    # run_puppet.bat files are called. These set up the required environment
    # for the program, and elevate.exe gives the program the elevated
    # privileges it needs to run
    pkg.add_source "file://resources/files/windows/elevate.exe.config", sum: "a5aecf3f7335fa1250a0f691d754d561"
    pkg.add_source "#{settings[:buildsources_url]}/windows/elevate/elevate.exe", sum: "bd81807a5c13da32dd2a7157f66fa55d"
    pkg.install_file 'elevate.exe.config', "#{settings[:windows_tools]}/elevate.exe.config"
    pkg.install_file 'elevate.exe', "#{settings[:windows_tools]}/elevate.exe"

    # We need to make sure we're setting permissions correctly for the executables
    # in the ruby bindir since preserving permissions in archives in windows is
    # ... weird, and we need to be able to use cygwin environment variable use
    # so cmd.exe was not working as expected.
    install_command = [
      "gunzip -c #{tarball_name} | tar -k -C /cygdrive/c/ -xf -",
      "chmod 755 #{settings[:ruby_bindir].sub(/C:/, '/cygdrive/c')}/*"
    ]
  elsif platform.is_macos?
    # We can't untar into '/' because of SIP on macOS; Just copy the contents
    # of these directories instead:
    install_command = [
      "tar -xzf #{tarball_name}",
      "for d in opt var private; do rsync -ka \"$${d}/\" \"/$${d}/\"; done"
    ]
  else
    install_command = ["gunzip -c #{tarball_name} | #{platform.tar} -k -C / -xf -"]
  end

  pkg.install do
    install_command
  end
end
