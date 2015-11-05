# Add /opt/puppetlabs/bin to the path for sh compatible users

if ! echo $PATH | grep -q /opt/puppetlabs/bin ; then
  export PATH=$PATH:/opt/puppetlabs/bin
fi
