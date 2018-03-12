component "cpp-hocon-source" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/cpp-hocon.json')

  pkg.build do
    [
      "mkdir -p #{settings[:gemdir]}/ext/facter/cpp-hocon",
      "cp -r * #{settings[:gemdir]}/ext/facter/cpp-hocon"
    ]
  end
end
