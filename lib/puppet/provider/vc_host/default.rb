# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_host).provide(:vc_host, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter hosts."

  def create
    sslThumbprint = resource[:sslthumbprint]
    retry_attempt = 0

    begin
      spec = {
        :force         => true,
        :hostName      => resource[:name],
        :userName      => resource[:username],
        :password      => resource[:password],
        :sslThumbprint => sslThumbprint,
      }

      o = vmfolder(resource[:path])
      if o.respond_to? :AddStandaloneHost_Task
        o.AddStandaloneHost_Task(
          :spec => spec, :addConnected => true).wait_for_completion
      elsif o.respond_to? :AddHost_Task
        o.AddHost_Task(
          :spec => spec, :asConnected => true).wait_for_completion
      else
        fail "unsupported operation: attempt to add host to object of class #{o.class}"
      end
    rescue RbVmomi::VIM::SSLVerifyFault
      unless resource[:secure]
        sslThumbprint = $!.fault.thumbprint
        Puppet.debug "Trusting insecure SSL Thumbprint: #{sslThumbprint}"
        retry_attempt += 1
        retry if retry_attempt <= 1
      end
      raise
    end
  end

  def destroy
    Puppet.debug "Removing host from Vcenter/cluster."

    begin
      parentFolder = @host.parent
      if parentFolder.to_s =~ /ClustercomputeResource/i
        # remove host from cluster
        @host.Destroy_Task.wait_for_completion
      else
        # remove host from datacenter
        @host.parent.Destroy_Task.wait_for_completion
      end
    rescue Exception => excep
      Puppet.err "Unable to perform the operation because the following exception occurred."
      Puppet.err excep.message
    end
  end

  # TODO: implement real path checking.
  def path
    resource[:path]
  end

  def path=(value)
  end

  def exists?
    find_host ? true : false
  end

  private

  def walk_dc(path=resource[:path])
    @datacenter = walk(path, RbVmomi::VIM::Datacenter)
    raise Puppet::Error.new( "No datacenter in path: #{path}") unless @datacenter
    @datacenter
  end

  def find_host
    @host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:name], :vmSearch => false)
  end
end

