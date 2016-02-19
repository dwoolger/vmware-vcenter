# Copyright (C) 2013 VMware, Inc.
# vCenter common parameters
class vcenter::params {

# Because PuppetLabs broke the puppetversion fact we need to fudge this temporarily 
# to get it moving forward. Once there is a reliable way to determine the Puppet Version 
# and determine whether it is PE then we can kill this fudge. Until then...

  if $::puppetversion =~ /Puppet Enterprise/ {
    $provider  = 'puppet_gem'
    $ruby_path = '/opt/puppetlabs/puppet/bin/gem'
  } else {

# The commented out values should be put back once we can determine reliably if we are running PE.
#    $provider  = 'gem'
#    $ruby_path = '/usr/bin/env ruby'
    $provider  = 'puppet_gem'
    $ruby_path = '/opt/puppetlabs/puppet/bin/gem'
  }

}
