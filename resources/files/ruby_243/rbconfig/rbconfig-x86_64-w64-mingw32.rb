# Custom rbconfig.rb file obtained from a test Ruby 2.4 build and modified
# to change build_os to "mingw32" as per PA-1086
#
# frozen-string-literal: false
#
# The module storing Ruby interpreter configurations on building.
#
# This file was created by mkconfig.rb when ruby was built.  It contains
# build information for ruby which is used e.g. by mkmf to build
# compatible native extensions.  Any changes made to this file will be
# lost the next time ruby is built.

module RbConfig
  RUBY_VERSION.start_with?("2.4.") or
    raise "ruby lib version (2.4.3) doesn't match executable version (#{RUBY_VERSION})"

  # Ruby installed directory.
  TOPDIR = File.dirname(__FILE__).chomp!("/lib/ruby/2.4.0/x64-mingw32")
  # DESTDIR on make install.
  DESTDIR = TOPDIR && TOPDIR[/\A[a-z]:/i] || '' unless defined? DESTDIR
  # The hash configurations stored.
  CONFIG = {}
  CONFIG["DESTDIR"] = DESTDIR
  CONFIG["MAJOR"] = "2"
  CONFIG["MINOR"] = "4"
  CONFIG["TEENY"] = "3"
  CONFIG["PATCHLEVEL"] = "205"
  CONFIG["INSTALL"] = '/bin/install -c'
  CONFIG["EXEEXT"] = ".exe"
  CONFIG["prefix"] = (TOPDIR || DESTDIR + "C:/ProgramFiles64Folder/PuppetLabs/Puppet/sys/ruby")
  CONFIG["ruby_install_name"] = "$(RUBY_BASE_NAME)"
  CONFIG["RUBY_INSTALL_NAME"] = "$(RUBY_BASE_NAME)"
  CONFIG["RUBY_SO_NAME"] = "x64-msvcrt-$(RUBY_BASE_NAME)$(MAJOR)$(MINOR)0"
  CONFIG["exec"] = "exec"
  CONFIG["ruby_pc"] = "ruby-2.4.pc"
  CONFIG["PACKAGE"] = "ruby"
  CONFIG["BUILTIN_TRANSSRCS"] = " enc/trans/newline.c"
  CONFIG["USE_RUBYGEMS"] = "YES"
  CONFIG["MANTYPE"] = "doc"
  CONFIG["NROFF"] = "/usr/bin/nroff"
  CONFIG["vendorarchhdrdir"] = "$(vendorhdrdir)/$(sitearch)"
  CONFIG["sitearchhdrdir"] = "$(sitehdrdir)/$(sitearch)"
  CONFIG["rubyarchhdrdir"] = "$(rubyhdrdir)/$(arch)"
  CONFIG["vendorhdrdir"] = "$(rubyhdrdir)/vendor_ruby"
  CONFIG["sitehdrdir"] = "$(rubyhdrdir)/site_ruby"
  CONFIG["rubyhdrdir"] = "$(includedir)/$(RUBY_VERSION_NAME)"
  CONFIG["RUBY_SEARCH_PATH"] = ""
  CONFIG["UNIVERSAL_INTS"] = ""
  CONFIG["UNIVERSAL_ARCHNAMES"] = ""
  CONFIG["configure_args"] = " '--enable-shared' '--enable-bundled-libyaml' '--disable-install-doc' '--disable-install-rdoc' '--host' 'x86_64-w64-mingw32' 'CPPFLAGS=-DFD_SETSIZE=2048' 'debugflags=-g' '--prefix=C:/ProgramFiles64Folder/PuppetLabs/Puppet/sys/ruby' '--with-opt-dir=C:/ProgramFiles64Folder/PuppetLabs/Puppet/puppet' 'host_alias=x86_64-w64-mingw32' 'LDFLAGS=-LC:/tools/pl-build-tools/lib -LC:/tools/mingw64/lib -LC:/ProgramFiles64Folder/PuppetLabs/Puppet/sys/ruby/lib'"
  CONFIG["CONFIGURE"] = "configure"
  CONFIG["vendorarchdir"] = "$(vendorlibdir)/$(sitearch)"
  CONFIG["vendorlibdir"] = "$(vendordir)/$(ruby_version)"
  CONFIG["vendordir"] = "$(rubylibprefix)/vendor_ruby"
  CONFIG["sitearchdir"] = "$(sitelibdir)/$(sitearch)"
  CONFIG["sitelibdir"] = "$(sitedir)/$(ruby_version)"
  CONFIG["sitedir"] = "$(rubylibprefix)/site_ruby"
  CONFIG["rubyarchdir"] = "$(rubylibdir)/$(arch)"
  CONFIG["rubylibdir"] = "$(rubylibprefix)/$(ruby_version)"
  CONFIG["ruby_version"] = "2.4.0"
  CONFIG["sitearch"] = "x64-msvcrt"
  CONFIG["arch"] = "x64-mingw32"
  CONFIG["sitearchincludedir"] = "$(includedir)/$(sitearch)"
  CONFIG["archincludedir"] = "$(includedir)/$(arch)"
  CONFIG["sitearchlibdir"] = "$(libdir)/$(sitearch)"
  CONFIG["archlibdir"] = "$(libdir)/$(arch)"
  CONFIG["libdirname"] = "libdir"
  CONFIG["RUBY_EXEC_PREFIX"] = ""
  CONFIG["RUBY_LIB_VERSION"] = ""
  CONFIG["RUBY_LIB_VERSION_STYLE"] = "3\t/* full */"
  CONFIG["RI_BASE_NAME"] = "ri"
  CONFIG["ridir"] = "$(datarootdir)/$(RI_BASE_NAME)"
  CONFIG["rubysitearchprefix"] = "$(rubylibprefix)/$(sitearch)"
  CONFIG["rubyarchprefix"] = "$(rubylibprefix)/$(arch)"
  CONFIG["MAKEFILES"] = "Makefile GNUmakefile"
  CONFIG["PLATFORM_DIR"] = "win32"
  CONFIG["THREAD_MODEL"] = "win32"
  CONFIG["SYMBOL_PREFIX"] = ""
  CONFIG["EXPORT_PREFIX"] = " "
  CONFIG["COMMON_HEADERS"] = "winsock2.h windows.h"
  CONFIG["COMMON_MACROS"] = ""
  CONFIG["COMMON_LIBS"] = "m"
  CONFIG["MAINLIBS"] = ""
  CONFIG["ENABLE_SHARED"] = "yes"
  CONFIG["DLDLIBS"] = ""
  CONFIG["SOLIBS"] = "$(LIBS)"
  CONFIG["LIBRUBYARG_SHARED"] = "-l$(RUBY_SO_NAME)"
  CONFIG["LIBRUBYARG_STATIC"] = "-l$(RUBY_SO_NAME)-static"
  CONFIG["LIBRUBYARG"] = "$(LIBRUBYARG_SHARED)"
  CONFIG["LIBRUBY"] = "lib$(RUBY_SO_NAME).dll.a"
  CONFIG["LIBRUBY_ALIASES"] = ""
  CONFIG["LIBRUBY_SO"] = "$(RUBY_SO_NAME).dll"
  CONFIG["LIBRUBY_A"] = "lib$(RUBY_SO_NAME)-static.a"
  CONFIG["RUBYW_INSTALL_NAME"] = "$(RUBYW_BASE_NAME)"
  CONFIG["rubyw_install_name"] = "$(RUBYW_INSTALL_NAME)"
  CONFIG["EXTDLDFLAGS"] = ""
  CONFIG["EXTLDFLAGS"] = "-static-libgcc"
  CONFIG["strict_warnflags"] = ""
  CONFIG["warnflags"] = "-Wall -Wextra -Wno-unused-parameter -Wno-parentheses -Wno-long-long -Wno-missing-field-initializers -Wno-tautological-compare -Wno-parentheses-equality -Wno-constant-logical-operand -Wno-self-assign -Wunused-variable -Wimplicit-int -Wpointer-arith -Wwrite-strings -Wdeclaration-after-statement -Wimplicit-function-declaration -Wdeprecated-declarations -Wno-packed-bitfield-compat -Wsuggest-attribute=noreturn -Wsuggest-attribute=format -Wno-maybe-uninitialized"
  CONFIG["debugflags"] = "-g"
  CONFIG["optflags"] = "-IC:/tools/pl-build-tools/include -IC:/tools/mingw64/include -IC:/ProgramFiles64Folder/PuppetLabs/Puppet/puppet/include -O3 -fno-omit-frame-pointer -fno-fast-math"
  CONFIG["NULLCMD"] = ":"
  CONFIG["DLNOBJ"] = "dln.o"
  CONFIG["INSTALL_STATIC_LIBRARY"] = "no"
  CONFIG["EXECUTABLE_EXTS"] = ".exe .com .cmd .bat"
  CONFIG["ARCHFILE"] = ""
  CONFIG["LIBRUBY_RELATIVE"] = "yes"
  CONFIG["EXTOUT"] = ".ext"
  CONFIG["PREP"] = "miniruby$(EXEEXT)"
  CONFIG["CROSS_COMPILING"] = "no"
  CONFIG["TEST_RUNNABLE"] = "yes"
  CONFIG["rubylibprefix"] = "$(libdir)/$(RUBY_BASE_NAME)"
  CONFIG["setup"] = "Setup"
  CONFIG["ENCSTATIC"] = ""
  CONFIG["EXTSTATIC"] = ""
  CONFIG["STRIP"] = "strip"
  CONFIG["TRY_LINK"] = ""
  CONFIG["PRELOADENV"] = ""
  CONFIG["LIBPATHENV"] = ""
  CONFIG["RPATHFLAG"] = ""
  CONFIG["LIBPATHFLAG"] = " -L%s"
  CONFIG["LINK_SO"] = ""
  CONFIG["ASMEXT"] = "S"
  CONFIG["LIBEXT"] = "a"
  CONFIG["DLEXT2"] = ""
  CONFIG["DLEXT"] = "so"
  CONFIG["LDSHAREDXX"] = "$(CXX) -shared $(if $(filter-out -g -g0,$(debugflags)),,-s)"
  CONFIG["LDSHARED"] = "$(CC) -shared $(if $(filter-out -g -g0,$(debugflags)),,-s)"
  CONFIG["CCDLFLAGS"] = ""
  CONFIG["STATIC"] = ""
  CONFIG["ARCH_FLAG"] = ""
  CONFIG["DLDFLAGS"] = "-LC:/tools/pl-build-tools/lib -LC:/tools/mingw64/lib -LC:/ProgramFiles64Folder/PuppetLabs/Puppet/sys/ruby/lib -Wl,--enable-auto-image-base,--enable-auto-import -LC/lib -L/ProgramFiles64Folder/PuppetLabs/Puppet/puppet/lib $(DEFFILE)"
  CONFIG["ALLOCA"] = ""
  CONFIG["codesign"] = ""
  CONFIG["POSTLINK"] = ":"
  CONFIG["WERRORFLAG"] = "-Werror"
  CONFIG["CHDIR"] = "cd -P"
  CONFIG["RMALL"] = "rm -fr"
  CONFIG["RMDIRS"] = "rmdir --ignore-fail-on-non-empty -p"
  CONFIG["RMDIR"] = "rmdir --ignore-fail-on-non-empty"
  CONFIG["CP"] = "cp"
  CONFIG["RM"] = "rm -f"
  CONFIG["PKG_CONFIG"] = ""
  CONFIG["PYTHON"] = ""
  CONFIG["DOXYGEN"] = ""
  CONFIG["DOT"] = ""
  CONFIG["MAKEDIRS"] = "/bin/mkdir -p"
  CONFIG["MKDIR_P"] = "/bin/mkdir -p"
  CONFIG["INSTALL_DATA"] = "$(INSTALL) -m 644"
  CONFIG["INSTALL_SCRIPT"] = "$(INSTALL)"
  CONFIG["INSTALL_PROGRAM"] = "$(INSTALL)"
  CONFIG["SET_MAKE"] = ""
  CONFIG["LN_S"] = "ln -s"
  CONFIG["NM"] = "nm"
  CONFIG["DLLWRAP"] = "dllwrap"
  CONFIG["WINDRES"] = "windres"
  CONFIG["OBJCOPY"] = ":"
  CONFIG["OBJDUMP"] = "objdump"
  CONFIG["ASFLAGS"] = ""
  CONFIG["AS"] = "as"
  CONFIG["ARFLAGS"] = "rcD "
  CONFIG["AR"] = "ar"
  CONFIG["RANLIB"] = "ranlib"
  CONFIG["try_header"] = ""
  CONFIG["CC_VERSION_MESSAGE"] = "x86_64-w64-mingw32-gcc.exe (x86_64-win32-seh-rev0, Built by MinGW-W64 project) 5.2.0\nCopyright (C) 2015 Free Software Foundation, Inc.\nThis is free software; see the source for copying conditions.  There is NO\nwarranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\n\r"
  CONFIG["CC_VERSION"] = "$(CC) --version"
  CONFIG["CSRCFLAG"] = ""
  CONFIG["COUTFLAG"] = "-o "
  CONFIG["OUTFLAG"] = "-o "
  CONFIG["CPPOUTFILE"] = "-o conftest.i"
  CONFIG["GNU_LD"] = "no"
  CONFIG["LD"] = "ld"
  CONFIG["GCC"] = "yes"
  CONFIG["EGREP"] = "/bin/grep -E"
  CONFIG["GREP"] = "/bin/grep"
  CONFIG["CPP"] = "$(CC) -E"
  CONFIG["CXXFLAGS"] = "$(cxxflags)"
  CONFIG["OBJEXT"] = "o"
  CONFIG["CPPFLAGS"] = "-DFD_SETSIZE=2048 -IC/include -I/ProgramFiles64Folder/PuppetLabs/Puppet/puppet/include -D_WIN32_WINNT=0x0501 -D__MINGW_USE_VC2005_COMPAT $(DEFS) $(cppflags)"
  CONFIG["LDFLAGS"] = "-L. -LC:/tools/pl-build-tools/lib -LC:/tools/mingw64/lib -LC:/ProgramFiles64Folder/PuppetLabs/Puppet/sys/ruby/lib -LC/lib -L/ProgramFiles64Folder/PuppetLabs/Puppet/puppet/lib"
  CONFIG["CFLAGS"] = "$(cflags)"
  CONFIG["CXX"] = "x86_64-w64-mingw32-g++"
  CONFIG["CC"] = "x86_64-w64-mingw32-gcc"
  CONFIG["NACL_LIB_PATH"] = ""
  CONFIG["NACL_SDK_VARIANT"] = ""
  CONFIG["NACL_SDK_ROOT"] = ""
  CONFIG["NACL_TOOLCHAIN"] = ""
  CONFIG["target_os"] = "mingw32"
  CONFIG["target_vendor"] = "w64"
  CONFIG["target_cpu"] = "x64"
  CONFIG["target"] = "x86_64-w64-mingw32"
  CONFIG["host_os"] = "mingw32"
  CONFIG["host_vendor"] = "w64"
  CONFIG["host_cpu"] = "x86_64"
  CONFIG["host"] = "x86_64-w64-mingw32"
  CONFIG["RUBY_VERSION_NAME"] = "$(RUBY_BASE_NAME)-$(ruby_version)"
  CONFIG["RUBYW_BASE_NAME"] = "rubyw"
  CONFIG["RUBY_BASE_NAME"] = "ruby"
  CONFIG["build_os"] = "mingw32"
  CONFIG["build_vendor"] = "unknown"
  CONFIG["build_cpu"] = "x86_64"
  CONFIG["build"] = "x86_64-unknown-cygwin"
  CONFIG["RUBY_PROGRAM_VERSION"] = "2.4.3"
  CONFIG["cxxflags"] = "$(optflags) $(debugflags) $(warnflags)"
  CONFIG["cppflags"] = ""
  CONFIG["cflags"] = "$(optflags) $(debugflags) $(warnflags)"
  CONFIG["target_alias"] = ""
  CONFIG["host_alias"] = "x86_64-w64-mingw32"
  CONFIG["build_alias"] = ""
  CONFIG["LIBS"] = "-lshell32 -lws2_32 -liphlpapi -limagehlp -lshlwapi "
  CONFIG["ECHO_T"] = ""
  CONFIG["ECHO_N"] = "-n"
  CONFIG["ECHO_C"] = ""
  CONFIG["DEFS"] = "-D_FILE_OFFSET_BITS=64"
  CONFIG["mandir"] = "$(datarootdir)/man"
  CONFIG["localedir"] = "$(datarootdir)/locale"
  CONFIG["libdir"] = "$(exec_prefix)/lib"
  CONFIG["psdir"] = "$(docdir)"
  CONFIG["pdfdir"] = "$(docdir)"
  CONFIG["dvidir"] = "$(docdir)"
  CONFIG["htmldir"] = "$(docdir)"
  CONFIG["infodir"] = "$(datarootdir)/info"
  CONFIG["docdir"] = "$(datarootdir)/doc/$(PACKAGE)"
  CONFIG["oldincludedir"] = "/usr/include"
  CONFIG["includedir"] = "$(prefix)/include"
  CONFIG["localstatedir"] = "$(prefix)/var"
  CONFIG["sharedstatedir"] = "$(prefix)/com"
  CONFIG["sysconfdir"] = "$(prefix)/etc"
  CONFIG["datadir"] = "$(datarootdir)"
  CONFIG["datarootdir"] = "$(prefix)/share"
  CONFIG["libexecdir"] = "$(exec_prefix)/libexec"
  CONFIG["sbindir"] = "$(exec_prefix)/sbin"
  CONFIG["bindir"] = "$(exec_prefix)/bin"
  CONFIG["exec_prefix"] = "$(prefix)"
  CONFIG["PACKAGE_URL"] = ""
  CONFIG["PACKAGE_BUGREPORT"] = ""
  CONFIG["PACKAGE_STRING"] = ""
  CONFIG["PACKAGE_VERSION"] = ""
  CONFIG["PACKAGE_TARNAME"] = ""
  CONFIG["PACKAGE_NAME"] = ""
  CONFIG["PATH_SEPARATOR"] = ":"
  CONFIG["SHELL"] = "/bin/sh"
  CONFIG["UNICODE_VERSION"] = "9.0.0"
  CONFIG["archdir"] = "$(rubyarchdir)"
  CONFIG["topdir"] = File.dirname(__FILE__)
  # Almost same with CONFIG. MAKEFILE_CONFIG has other variable
  # reference like below.
  #
  #   MAKEFILE_CONFIG["bindir"] = "$(exec_prefix)/bin"
  #
  # The values of this constant is used for creating Makefile.
  #
  #   require 'rbconfig'
  #
  #   print <<-END_OF_MAKEFILE
  #   prefix = #{Config::MAKEFILE_CONFIG['prefix']}
  #   exec_prefix = #{Config::MAKEFILE_CONFIG['exec_prefix']}
  #   bindir = #{Config::MAKEFILE_CONFIG['bindir']}
  #   END_OF_MAKEFILE
  #
  #   => prefix = /usr/local
  #      exec_prefix = $(prefix)
  #      bindir = $(exec_prefix)/bin  MAKEFILE_CONFIG = {}
  #
  # RbConfig.expand is used for resolving references like above in rbconfig.
  #
  #   require 'rbconfig'
  #   p Config.expand(Config::MAKEFILE_CONFIG["bindir"])
  #   # => "/usr/local/bin"
  MAKEFILE_CONFIG = {}
  CONFIG.each{|k,v| MAKEFILE_CONFIG[k] = v.dup}

  # call-seq:
  #
  #   RbConfig.expand(val)         -> string
  #   RbConfig.expand(val, config) -> string
  #
  # expands variable with given +val+ value.
  #
  #   RbConfig.expand("$(bindir)") # => /home/foobar/all-ruby/ruby19x/bin
  def RbConfig::expand(val, config = CONFIG)
    newval = val.gsub(/\$\$|\$\(([^()]+)\)|\$\{([^{}]+)\}/) {
      var = $&
      if !(v = $1 || $2)
	'$'
      elsif key = config[v = v[/\A[^:]+(?=(?::(.*?)=(.*))?\z)/]]
	pat, sub = $1, $2
	config[v] = false
	config[v] = RbConfig::expand(key, config)
	key = key.gsub(/#{Regexp.quote(pat)}(?=\s|\z)/n) {sub} if pat
	key
      else
	var
      end
    }
    val.replace(newval) unless newval == val
    val
  end
  CONFIG.each_value do |val|
    RbConfig::expand(val)
  end

  # call-seq:
  #
  #   RbConfig.ruby -> path
  #
  # returns the absolute pathname of the ruby command.
  def RbConfig.ruby
    File.join(
      RbConfig::CONFIG["bindir"],
      RbConfig::CONFIG["ruby_install_name"] + RbConfig::CONFIG["EXEEXT"]
    )
  end
end
CROSS_COMPILING = nil unless defined? CROSS_COMPILING
