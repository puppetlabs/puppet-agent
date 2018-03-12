component "leatherman-source" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/leatherman.json')

  pkg.build do
    [
      "mkdir -p #{settings[:gemdir]}/ext/facter/leatherman",
      "cp -r * #{settings[:gemdir]}/ext/facter/leatherman"
    ]
  end
end
