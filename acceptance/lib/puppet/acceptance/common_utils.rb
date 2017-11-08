module Puppet
  module Acceptance
    module CommandUtils
      def ruby_command(host)
        "env PATH=\"#{host['privatebindir']}:${PATH}\" ruby"
      end
      module_function :ruby_command

      def gem_command(host, type='aio')
        command(host, 'gem', type)
      end
      module_function :gem_command

      def irb_command(host, type='aio')
        command(host, 'irb', type)
      end
      module_function :irb_command

      def command(host, cmd, type)
        return on(host, "which #{cmd}").stdout.chomp unless type == 'aio'
        return "env PATH=\"#{host['privatebindir']}:${PATH}\" cmd /c #{cmd}" if host['platform'] =~ /windows/
        "env PATH=\"#{host['privatebindir']}:${PATH}\" #{cmd}"
      end
    end
  end
end
