component "nssm" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/nssm.json")

  build_arch = platform.architecture == "x64" ? "x64" : "Win32"

  pkg.install do
    [
      "/cygdrive/c/Program\\ files\\ \\(x86\\)/Microsoft\\ Visual\\ Studio/2017/BuildTools/Common7/Tools/vsdevcmd.bat",
      "/cygdrive/c/Program\\ Files\\ \\(x86\\)/Microsoft\\ Visual\\ Studio/2017/BuildTools/MSBuild/15.0/Bin/msbuild.exe nssm.vcxproj /detailedsummary /p:Configuration=Release /p:OutDir=./out /p:Platform=#{build_arch} /p:PlatformToolset=v141 /p:TargetPlatformVersion=8.1",
    ]
  end

  pkg.install_file "out/nssm.exe", "#{settings[:service_dir]}/nssm.exe"
end
