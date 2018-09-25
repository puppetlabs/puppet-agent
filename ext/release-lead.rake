require 'json'
require 'optparse'
require 'yaml'

namespace :release_lead do
  desc "Find platforms added and removed between releases"
  task :platform_diff, [:from, :to] do |t, args|
    abort ('`from` argument is required') unless args.from
    abort ('`to` argument is required') unless args.to
    puts "Platform Changes:"
    puts
    puts `git diff --summary #{args.from}..#{args.to} configs/platforms`.
        gsub('configs/platforms/', '').gsub(/mode \d+ /, '').
        gsub('delete', 'Retired').gsub('create', 'Added').
        gsub('rename', 'Renamed')
  end

  desc "List currently supported platforms on the current branch"
  task :supported_platforms do |t, args|
    puts "Currently Supported Platforms:"
    puts
    platform_names = Dir.glob("./configs/platforms/*").map do |platform_file|
      File.basename(platform_file).gsub(".rb",'')
    end
    platform_names.each do |_platform|
      # Aix platforms are _awesome_, we use -ppc as the name of the arch in the vanagon file for AIX (since that's
      # what the package will look like). However, every other piece of our automation uses -power. Thus we just replace
      # -ppc with -power
      platform = _platform.gsub(/-ppc$/, '-power')
      build_defaults = YAML.load_file('./ext/build_defaults.yaml')
      if build_defaults['pe_platforms'].include?(platform)
        puts "PE Only -- " + platform
      else
        puts "           " + platform
      end
    end
  end

  # Calculate name of repository from the .git URL.
  def url_to_component_name(url)
    url.split('/').last.split('.').first
  end

  # Calculate name of repository from the name of the component's .json file.
  def json_name_to_component_name(json_filename)
    json_filename.split('/').last.split('.').first
  end

  # Input a git repository, a SHA or tag to check out, and a place where it can be cloned.
  # Output the resulting `git describe` for that reference.
  def git_describe_repo(name, url, sha_or_tag, where_to_clone, show_extra_commits)
    Dir.chdir(where_to_clone) do
      puts "Cloning #{name}..."
      `git clone #{url} 2> /dev/null`
      # `git clone --local '../../#{name}' 2> /dev/null`
      # 0 for successful clone, 128 for already exists.
      unless [0, 128].include? $?.exitstatus
        next 'Could not find remote repository'
      end
      Dir.chdir(name) do
        `git fetch 2> /dev/null`
        `git checkout #{sha_or_tag} 2> /dev/null`
        unless $?.exitstatus == 0
          puts "Could not find reference #{sha_or_tag}"
          exit
        end
        `git describe --tags`.strip +
            if show_extra_commits
              lines = `git log \`git describe --tags --abbrev=0\`..HEAD --oneline`.split("\n")
              lines.map do |value|
                if value.include?('[no-promote]')
                  # Output these in red.
                  "\e[31m#{value}\e[0m"
                else
                  value
                end
              end.join("\n  ")
            else
              ''
            end
      end
    end
  end

  def check_components(args, show_extra_commits = false)
    result = {}
    abort('Error: puppet_agent_branch argument is required') unless args.puppet_agent_branch

    where_to_clone = File.join(File.dirname(__FILE__), 'pkg')
    Dir.mkdir(where_to_clone) unless Dir.exists?(where_to_clone)

    # Let's ensure puppet-agent is on the right branch.
    `git fetch`
    begin
      `git checkout #{args.puppet_agent_branch} 2> /dev/null`

      Dir.glob("./configs/components/*.json").each do |component|
        json = JSON.parse(File.read(component))
        url = json['url']
        if url.nil?
          name = json_name_to_component_name(component)
          result[name] = 'No URL provided'
          next
        end
        name = url_to_component_name(url)
        ref = json['ref']
        sha_or_tag = ref =~ /^refs\/tags/ ? ref.gsub('refs/tags/', '') : ref
        result[name] = git_describe_repo(name, url, sha_or_tag, where_to_clone, show_extra_commits)
      end

      max_length = result.keys.map(&:length).max
      puts "\n** Latest versions in #{args.puppet_agent_branch}:\n"
      result.map do |name, value|
        puts name.ljust(max_length + 1) + ': ' + value
      end
    ensure
      `git checkout @{-1} 2> /dev/null`
    end
  end

  # This task performs the following for each repository:
  # - Looks up each component
  # - Clones the component into the 'pkg' directory, if not done already
  # - Checks out the git reference that's in the component's .json.
  # - Outputs the `git describe` for that reference.
  # This is useful for determining tag versions for an upcoming release.
  desc "Output `git describe` for each component's git branch"
  task :check_components_diff, [:puppet_agent_branch] do |t, args|
    check_components(args, true)
  end

  # This task performs the following for each repository:
  # - Looks up each component
  # - Clones the component into the 'pkg' directory, if not done already
  # - Checks out the git reference that's in the component's .json.
  # - Outputs the `git describe` for that reference.
  # This is useful for determining tag versions for an upcoming release.
  desc "Output `git describe` for each component's git branch"
  task :check_components, [:puppet_agent_branch] do |t, args|
    check_components(args, false)
  end
end
