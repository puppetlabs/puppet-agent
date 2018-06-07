RAKE_ROOT = File.expand_path(File.dirname(__FILE__))

begin
  load File.join(RAKE_ROOT, 'ext', 'packaging', 'packaging.rake')
rescue LoadError
end

build_defs_file = File.join(RAKE_ROOT, 'ext', 'build_defaults.yaml')
if File.exist?(build_defs_file)
  begin
    require 'yaml'
    @build_defaults ||= YAML.load_file(build_defs_file)
  rescue Exception => e
    STDERR.puts "Unable to load yaml from #{build_defs_file}:"
    raise e
  end
  @packaging_url  = @build_defaults['packaging_url']
  @packaging_repo = @build_defaults['packaging_repo']
  raise "Could not find packaging url in #{build_defs_file}" if @packaging_url.nil?
  raise "Could not find packaging repo in #{build_defs_file}" if @packaging_repo.nil?

  namespace :package do
 #   desc "Bootstrap packaging automation, e.g. clone into packaging repo"
    task :bootstrap do
      if File.exist?(File.join(RAKE_ROOT, "ext", @packaging_repo))
        puts "It looks like you already have ext/#{@packaging_repo}. If you don't like it, blow it away with package:implode."
      else
        cd File.join(RAKE_ROOT, 'ext') do
          %x{git clone #{@packaging_url}}
        end
      end
    end
 #   desc "Remove all cloned packaging automation"
    task :implode do
      rm_rf File.join(RAKE_ROOT, "ext", @packaging_repo)
    end
  end
end

desc "verify that commit messages match CONTRIBUTING.md requirements"
task(:commits) do
  commits = ENV['TRAVIS_COMMIT_RANGE']
  if commits.nil?
    puts "TRAVIS_COMMIT_RANGE is undefined, I don't know what to check."
    exit
  end

  %x{git log --no-merges --pretty=%s #{commits}}.each_line do |commit_summary|
    error_message=<<-HEREDOC
\n\n\n\tThis commit summary didn't match CONTRIBUTING.md guidelines:\n \
\n\t\t#{commit_summary}\n \
\tThe commit summary (i.e. the first line of the commit message) should start with one of:\n  \
\t\t(docs)\n \
\t\t(maint)\n \
\t\t(packaging)\n \
\t\t(<ANY PUBLIC JIRA TICKET>)\n \
\n\tThis test for the commit summary is case-insensitive.\n\n\n
    HEREDOC

    if /^\((maint|doc|docs|packaging)\)|revert|bumping|merge|promoting/i.match(commit_summary).nil?
      ticket = commit_summary.match(/^\(([[:alpha:]]+-[[:digit:]]+)\).*/)
      if ticket.nil?
        raise error_message
      else
        require 'net/http'
        require 'uri'
        uri = URI.parse("https://tickets.puppetlabs.com/browse/#{ticket[1]}")
        response = Net::HTTP.get_response(uri)
        if response.code != "200"
          raise error_message
        end
      end
    end
  end
end

