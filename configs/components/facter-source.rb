component "facter-source" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/facter.json')

  pkg.build do
    [
      "mkdir -p #{settings[:gemdir]}/ext/facter/facter",
      "cp -r * #{settings[:gemdir]}/ext/facter/facter"
    ]
  end
end
