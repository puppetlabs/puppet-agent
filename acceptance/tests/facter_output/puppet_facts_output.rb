
agents.each do |agent|
  on agent, puppet("facts"), :acceptable_exit_codes => [0] do 
    facter_major_version = JSON.parse(stdout)["facterversion"]

    # save locally 
    folderpath = File.expand_path(File.join('output', 'facts', "#{facter_major_version}"))
    FileUtils.mkdir_p(folderpath)
    filepath = File.expand_path(File.join(folderpath, "#{agent.platform}.facts"))

    File.open(filepath, 'w') do |f|
      f.write(stdout)
    end
  end
end
