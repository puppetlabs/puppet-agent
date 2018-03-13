require 'json'
require 'octokit'

project "cfacter" do |proj|
  platform = proj.get_platform
  # We don't generate the version for the facter gem in the same way we do
  # for other vanagon projects. We read from the facter project to find facter's
  # version, then use release_from_git to decide if we are on an agent tag.
  # If we _are_ on an agent tag, the facter gem is versioned as:
  #   'facterX'.'facterY'.'facterZ'.'date'
  # if we _are not_ at a tag the version will be:
  #   'facterX'.'facterY'.'facterZ'.rc.'date'
  facter_data = JSON.parse(File.read(File.join(File.dirname(__FILE__), '../components/facter.json')))
  facter_version_file = Base64.decode64(Octokit::Client.new.contents('puppetlabs/facter', path: 'CMakeLists.txt', ref: facter_data['ref']).content)
  facter_version = facter_version_file.match(/project\(FACTER VERSION [\d\.]*\)/).to_s.gsub(/[^\d\.]/, '')
  gem_version = facter_version
  # identify if we are at a tag. Git sets the release to '0' when we are on a tag
  # note that we ignore the actual value of release_from_git other than to check
  # if it was 0
  proj.release_from_git
  if proj._project.release.to_s == '0'
    gem_version += '.'
  else
    gem_version += ".rc."
  end
  gem_version += Time.now.strftime("%Y%m%d")
  proj.version gem_version

  proj.setting(:project_version, gem_version)
  proj.setting(:gemdir, '/var/tmp/facter_gem')
  if platform.is_windows?
    proj.setting(:artifactory_url, "https://artifactory.delivery.puppetlabs.net/artifactory")
    proj.setting(:buildsources_url, "#{proj.artifactory_url}/generic/buildsources")
    proj.setting(:ruby_dir, '/cygdrive/c/ProgramFiles64Folder/PuppetLabs/Puppet/sys/ruby')
    proj.setting(:ruby_bindir, File.join(proj.ruby_dir, 'bin'))
    proj.setting(:gem_binary, 'cmd /c "C:\ProgramFiles64Folder\PuppetLabs\Puppet\sys\ruby\bin\gem.bat"')
    proj.setting(:ruby_binary, 'cmd /c "C:\ProgramFiles64Folder\PuppetLabs\Puppet\sys\ruby\bin\ruby.exe"')
    proj.setting(:build_tools_dir, '/cygdrive/c/tools/pl-build-tools/bin')
    arch = platform.architecture == "x64" ? "64" : "32"
    proj.setting(:gcc_bindir, "C:/tools/mingw#{arch}/bin")
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
  proj.component "cfacter-source-gem"
  proj.component "cfacter-precompiled-gem"
  proj.component "puppet-runtime"
  proj.fetch_artifact "#{settings[:gemdir]}/cfacter*.gem"
  proj.no_packaging true
end
