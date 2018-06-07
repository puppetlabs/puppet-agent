platform "windows-2012r2-x64" do |plat|
  plat.vmpooler_template "win-2012r2-x86_64"

  plat.servicetype "windows"
  visual_studio_version = '2017'
  visual_studio_sdk_version = 'win8.1'

  # We need to ensure we install chocolatey prior to adding any nuget repos. Otherwise, everything will fall over
  plat.add_build_repository "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/chocolatey/install-chocolatey.ps1"
  plat.add_build_repository "https://artifactory.delivery.puppetlabs.net/artifactory/api/nuget/nuget"

  # C:\tools is likely added by mingw, however because we also want to use that
  # dir for vsdevcmd.bat we create it for safety
  plat.provision_with "mkdir C:/tools"
  # We don't want to install any packages from the chocolatey repo by accident
  plat.provision_with "C:/ProgramData/chocolatey/bin/choco.exe update -y chocolatey"
  plat.provision_with "C:/ProgramData/chocolatey/bin/choco.exe sources remove -name chocolatey"

  plat.provision_with "C:/ProgramData/chocolatey/bin/choco.exe install -y mingw-w64 -version 5.2.0 -debug"
  plat.provision_with "C:/ProgramData/chocolatey/bin/choco.exe install -y Wix310 -version 3.10.2 -debug -x86"
  # We use cache-location in the following install because msvc has several long paths
  # if we do not update the cache location choco will fail because paths get too long
  plat.provision_with "C:/ProgramData/chocolatey/bin/choco.exe install msvc.#{visual_studio_version}-#{visual_studio_sdk_version}.sdk.en-us -y --cache-location=\"C:\\msvc\""
  # The following creates a batch file that will execute the vsdevcmd batch file located within visual studio.
  # We create the following batch file under C:\tools\vsdevcmd.bat so we can avoid using both the %ProgramFiles(x86)%
  # evironment var, as well as any spaces in the path when executing things with cygwin. This makes command execution
  # through cygwin much easier.
  #
  # Note that the unruly \'s in the following string escape the following sequence to literal chars: "\" and then \""
  plat.provision_with "touch C:/tools/vsdevcmd.bat && echo \"\\\"%ProgramFiles(x86)%\\Microsoft Visual Studio\\#{visual_studio_version}\\BuildTools\\Common7\\Tools\\vsdevcmd\\\"\" >> C:/tools/vsdevcmd.bat"

  plat.install_build_dependencies_with "C:/ProgramData/chocolatey/bin/choco.exe install -y"

  plat.make "/usr/bin/make"
  plat.patch "TMP=/var/tmp /usr/bin/patch.exe --binary"

  plat.platform_triple "x86_64-w64-mingw32"

  plat.package_type "msi"
  plat.output_dir "windows"
end
