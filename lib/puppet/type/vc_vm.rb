# Copyright (C) 2013 VMware, Inc.
#require 'pathname'
#vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
#require File.join vmware_module.path, 'lib/puppet/property/vmware'
Puppet::Type.newtype(:vc_vm) do
  @doc = "Manage vCenter VMs."
  ensurable do
    newvalue(:present) do
        provider.create
    end
    newvalue(:absent) do
        provider.destroy
    end
    defaultto(:present)
  end

  newproperty(:power_state) do
      desc "Power state of the vm."
      newvalues(:poweredOn, :poweredOff, :reset, :suspend)
  end

  newparam(:name, :namevar => true) do
    desc "The virtual machine name."
	validate do |value|
		unless value =~ /^\w+$/
		    raise ArgumentError, "%s is invalid vm name." % value
		end
	end
  end

  newparam(:cpucount) do 
    desc "Number of CPU."
  end

  newparam(:memory) do 
	desc "Amount of memory."
  end

  newparam(:graceful_shutdown) do
     desc "Do the gracefull shut down of vm."
     newvalues(:true, :false)
	 defaultto(:true)
  end

  newparam(:datacenter) do
    desc "Name of the datacenter."
	validate do |value|
		unless value =~ /^\w+$/
		    raise ArgumentError, "%s is invalid datacenter name." % value
		end
	end
  end

  #autorequire(:vc_folder) do
  #  Pathname.new(self[:path]).parent.to_s
  #end
end
