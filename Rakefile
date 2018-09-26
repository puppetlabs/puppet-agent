puts "hey I'm at the top of the Rakefile"
require 'packaging'

puts "cool we required packaging"
load './ext/release-lead.rake'
puts "loaded more stuff"
Pkg::Util::RakeUtils.load_packaging_tasks

puts "aight packaging tasks have been loaded"

namespace :package do
  task :bootstrap do
    puts 'Bootstrap is no longer needed, using packaging-as-a-gem'
  end
  task :implode do
    puts 'Implode is no longer needed, using packaging-as-a-gem'
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
