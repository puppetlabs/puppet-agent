component "nssm" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/nssm.json")

  build_arch = platform.architecture == "x64" ? "x64" : "Win32"
  platform_toolset = 'v141'
  target_platform_version = '8.1'

  pkg.install do
    [
      "#{settings[:msbuild]} nssm.vcxproj /detailedsummary /p:Configuration=Release /p:OutDir=.\\out\\ /p:Platform=#{build_arch} /p:PlatformToolset=#{platform_toolset} /p:TargetPlatformVersion=#{target_platform_version}",
    ]
  end

  pkg.install_file "out/nssm.exe", "#{settings[:service_dir]}/nssm.exe"
end
