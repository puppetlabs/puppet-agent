# -*- coding: utf-8 -*-
require 'json'
require 'net/http'

TAGS_REGEX = /^refs\/tags\/([A-Za-z\d.-]+)$/

GREEN   = "\e[0;32m"
YELLOW  = "\e[0;33m"
HRED    = "\e[1;31m"
RESET   = "\e[0m"

STATUSES = {
  :ok   => "[  #{GREEN}OK#{RESET}  ]",
  :fail => "[ #{HRED}FAIL#{RESET} ]",
  :skip => "[ #{GREEN}SKIP#{RESET} ]",
  :warn => "[ #{YELLOW}WARN#{RESET} ]"
}

# Print a status line of the form:
#  <name> <version>:                                    [  OK  ]
#
# If <msg> is provided, writes it indented on a newline
def print_status(name, version, status, msg = nil)
  prefix = "#{name} #{version}: ".ljust(66)
  puts prefix + STATUSES[status]
  puts "  #{msg}" if msg
end

# Wrap github API calls
#
class Github
  include Singleton

  def initialize
    @server = 'api.github.com'
    @port = 443
  end

  # Get the SHA that ref points to
  def get_sha(repo, ref)
    object = get_json("repos/puppetlabs/#{repo}/git/#{ref}")
    object ? object['object']['sha'] : nil
  end

  # Make a github HTTP request, returning the response as JSON.
  def get_json(path)
    uri = URI("https://#{@server}:#{@port}/#{path}")

    # see https://developer.github.com/v3/#current-version
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/vnd.github.v3+json'

    if ENV['GITHUB_AUTH_TOKEN']
      request['Authorization'] = "token #{ENV['GITHUB_AUTH_TOKEN']}"
    end

    response = connection.request(request)

    case response
    when Net::HTTPOK
      JSON.load(response.body)
    when Net::HTTPNotFound
      nil
    when Net::HTTPForbidden
      raise "Either resource doesn't exist or the request was rate limited"
    else
      raise "HTTP error #{response.code}: #{response.message}"
    end
  end

  def close
    if @connection
      @connection.finish
      @connection = nil
    end
  end

  private

  # Create a persistent http connection, must be explicitly closed.
  def connection
    @connection ||= Net::HTTP.start(@server, @port, :use_ssl => true)
  end
end

# Verify the component is tagged, and the tag points to the current
# head of the branch.
def check_component(github, comp)
  if comp.tag =~ /^[\d.]+$/
    comp.fail("Tag '#{comp.tag}' is not of the form 'refs/tags/#{comp.tag}'")
    return
  end

  if comp.tag !~ TAGS_REGEX
    comp.fail("Tag '#{comp.tag}' is invalid")
    return
  end

  # get the sha of the commit the tag points to
  tag_sha = github.get_sha(comp.repo, comp.tag)
  if tag_sha.nil?
    comp.fail("Tag doesn't exist")
    return
  end

  commit_sha = github.get_sha(comp.repo, "tags/#{tag_sha}")

  # get the sha that the head of the branch points to
  branch = "refs/heads/#{comp.branch}"
  head_sha   = github.get_sha(comp.repo, branch)
  if head_sha.nil?
    comp.fail("Branch '#{branch}' does not exist")
    return
  end

  if commit_sha == head_sha
    comp.ok
  else
    comp.warn(<<MSG)
Additional commits on branch '#{comp.branch}':
    tag    : #{tag_sha[0..9]} (#{comp.short_tag})
      └->  : #{commit_sha[0..9]}
    branch : #{head_sha[0..9]} (#{comp.branch})
MSG
  end
rescue => e
  comp.fail(e.message)
end

# Represents a component, with a repo, tag, and branch. The
# component name will either be the repo name or a friendly
# name if one is specified.
class Component < Struct.new(:repo, :tag, :branch, :name)
  # component name defaults to repo name
  def initialize(repo, tag, branch, name = repo)
    super
  end

  def short_tag
    if @short_tag.nil?
      if captures = tag.match(TAGS_REGEX)
        @short_tag = captures[1]
      else
        @short_tag = tag
      end
    end
    @short_tag
  end

  def ok
    print_status(name, short_tag, :ok)
  end

  def fail(msg)
    print_status(name, short_tag, :fail, msg)
  end

  def skip(msg)
    print_status(name, short_tag, :skip, msg)
  end

  def warn(msg)
    print_status(name, short_tag, :warn, msg)
  end
end

# Parse the component configuration. If the component has
# a url and ref, then yield the component. Components
# without a url or ref, e.g. nssm, are not yielded.
def parse_component(path, &block)
  name = File.basename(path, File.extname(path))
  comp = JSON.parse(File.read(path))

  if comp['url'].nil?
    print_status(name, nil, :fail, "URL is missing")
  elsif comp['ref']
    repo = name
    tag = comp['ref']
    branch = 'stable'

    # The name of most components map directly to the repo
    # and stable branch. Handle special cases
    case name
    when 'marionette-collective'
      yield Component.new(repo, tag, '2.8.x', 'mco')
    when 'puppet-ca-bundle'
      yield Component.new(repo, tag, 'master', 'puppet-ca')
    when 'windows_ruby'
      # ref contains two components, yield both
      yield Component.new('puppet-win32-ruby', tag['x86'], '2.1.x-x86', 'windows_ruby (x86)')
      yield Component.new('puppet-win32-ruby', tag['x64'], '2.1.x-x64', 'windows_ruby (x64)')
    when 'windows_puppet'
      yield Component.new('puppet_for_the_win', tag, branch, 'windows_puppet')
    else
      yield Component.new(repo, tag, branch)
    end
  else
    print_status(name, "<none>", :skip)
  end
end

namespace "release" do
  desc "Verify components are tagged"
  task "tag_check" do
    github = Github.instance
    begin
      Dir.glob(File.expand_path(File.join(__FILE__, '../../configs/components/*.json'))) do |path|
        parse_component(path) do |comp|
          check_component(github, comp)
        end
      end
    ensure
      github.close
    end
  end
end
