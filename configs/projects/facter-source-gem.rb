require 'json'
require 'octokit'

project "facter-source-gem" do |proj|
  platform = proj.get_platform
  # identify if we are at a tag. Git sets the release to '0' when we are on a tag
  # note that we ignore the actual value of release_from_git other than to check
  # if it was 0
  proj.release_from_git
  if proj._project.release.to_s == '0'
    gem_version = '.cfacter.'
  else
    gem_version = ".cfacter.rc."
  end
  gem_version += Time.now.strftime("%Y%m%d")
  proj.version gem_version

  proj.setting(:project_version, gem_version)
  proj.setting(:gemdir, '/var/tmp/facter_gem')
  if platform.is_windows?
    if platform.architecture == "x64"
      proj.setting(:ruby_dir, '/cygdrive/c/ProgramFiles64Folder/PuppetLabs/Puppet/sys/ruby')
      proj.setting(:gem_binary, 'cmd /c "C:\ProgramFiles64Folder\PuppetLabs\Puppet\sys\ruby\bin\gem.bat"')
      proj.setting(:ruby_binary, 'cmd /c "C:\ProgramFiles64Folder\PuppetLabs\Puppet\sys\ruby\bin\ruby.exe"')
      proj.setting(:gcc_bindir, "C:/tools/mingw64/bin")
    else
      proj.setting(:ruby_dir, '/cygdrive/c/ProgramFilesFolder/PuppetLabs/Puppet/sys/ruby')
      proj.setting(:gem_binary, 'cmd /c "C:\ProgramFilesFolder\PuppetLabs\Puppet\sys\ruby\bin\gem.bat"')
      proj.setting(:ruby_binary, 'cmd /c "C:\ProgramFilesFolder\PuppetLabs\Puppet\sys\ruby\bin\ruby.exe"')
      proj.setting(:gcc_bindir, "C:/tools/mingw32/bin")
    end
    proj.setting(:artifactory_url, "https://artifactory.delivery.puppetlabs.net/artifactory")
    proj.setting(:buildsources_url, "#{proj.artifactory_url}/generic/buildsources")
    proj.setting(:build_tools_dir, '/cygdrive/c/tools/pl-build-tools/bin')
    proj.setting(:ruby_bindir, File.join(proj.ruby_dir, 'bin'))
    proj.setting(:precompiled_spec_glob, "Dir.glob(['lib/**/*', 'bin/**/*'])")
  else
    proj.setting(:ruby_dir, '/opt/puppetlabs/puppet/bin')
    proj.setting(:gem_binary, File.join(proj.ruby_dir, 'gem'))
    proj.setting(:ruby_binary, File.join(proj.ruby_dir, 'ruby'))
    proj.setting(:build_tools_dir, '/opt/pl-build-tools/bin')
    proj.setting(:precompiled_spec_glob, "Dir.glob('lib/**/*')")
  end

  proj.component "facter-source"
  proj.component "leatherman-source"
  proj.component "cpp-hocon-source"
  proj.component "facter-source-gem"
  proj.component "puppet-runtime"
  proj.fetch_artifact "#{settings[:gemdir]}/facter*.gem"
  proj.no_packaging true
end
