require 'fog/compute/models/server'

module Fog
  module Compute
    class XenServer
      module Models
        class Server < Fog::Compute::Server
          # API Reference here:
          # http://docs.vmd.citrix.com/XenServer/6.2.0/1.0/en_gb/api/?c=VM

          identity :reference

          attribute :actions_after_crash
          attribute :actions_after_reboot
          attribute :actions_after_shutdown
          attribute :allowed_operations
          attribute :blobs
          attribute :blocked_operations
          attribute :bios_strings
          attribute :current_operations
          attribute :domarch
          attribute :domid
          attribute :description,                 :aliases => :name_description
          attribute :generation_id
          attribute :ha_always_run
          attribute :ha_restart_priority
          attribute :hvm_boot_params,             :aliases => :HVM_boot_params
          attribute :hvm_boot_policy,             :aliases => :HVM_boot_policy
          attribute :hvm_shadow_multiplier,       :aliases => :HVM_shadow_multiplier
          attribute :is_a_snapshot
          attribute :is_a_template
          attribute :is_control_domain
          attribute :is_snapshot_from_vmpp
          attribute :last_booted_record
          attribute :last_boot_cpu_flags,         :aliases => :last_boot_CPU_flags
          attribute :memory_dynamic_max
          attribute :memory_dynamic_min
          attribute :memory_overhead
          attribute :memory_static_max
          attribute :memory_static_min
          attribute :memory_target
          attribute :name,                        :aliases => :name_label
          attribute :order
          attribute :other_config
          attribute :pci_bus,                     :aliases => :PCI_bus
          attribute :platform
          attribute :power_state
          attribute :pv_args,                     :aliases => :PV_args
          attribute :pv_bootloader,               :aliases => :PV_bootloader
          attribute :pv_bootloader_args,          :aliases => :PV_bootloader_args
          attribute :pv_kernel,                   :aliases => :PV_kernel
          attribute :pv_legacy_args,              :aliases => :PV_legacy_args
          attribute :pv_ramdisk,                  :aliases => :PV_ramdisk
          attribute :recommendations
          attribute :shutdown_delay
          attribute :snapshot_info
          attribute :snapshot_metadata
          attribute :snapshot_time
          attribute :start_delay
          attribute :tags
          attribute :template_name
          attribute :transportable_snapshot_id
          attribute :user_version
          attribute :uuid
          attribute :vcpus_at_startup,            :aliases => :VCPUs_at_startup
          attribute :vcpus_max,                   :aliases => :VCPUs_max
          attribute :vcpus_params,                :aliases => :VCPUs_params
          attribute :version
          attribute :xenstore_data

          has_one   :affinity,          :hosts
          has_one   :appliance,         :server_appliances
          has_many  :attached_pcis,     :pcis,                    :aliases => :attached_PCIs
          has_many  :children,          :servers
          has_many  :consoles,          :consoles
          has_many  :crash_dumps,       :crash_dumps
          has_one   :guest_metrics,     :guests_metrics
          has_one   :metrics,           :servers_metrics
          has_one   :parent,            :servers
          has_one   :protection_policy, :vmpps
          has_one   :resident_on,       :hosts
          has_many  :snapshots,         :servers
          has_one   :snapshot_of,       :servers
          has_one   :suspend_sr,        :storage_repositories,    :aliases => :suspend_SR
          has_one   :suspend_vdi,       :vdis,                    :aliases => :suspend_VDI
          has_many  :vbds,              :vbds,                    :aliases => :VBDs
          has_many  :vgpus,             :vgpus,                   :aliases => :VGPUs
          has_many  :vifs,              :vifs,                    :aliases => :VIFs
          has_many  :vtpms,             :vtpms,                   :aliases => :VTPMs

          def destroy
            # Make sure it's halted
            stop('hard')
            vbds.each do |vbd|
              if vbd.type == "Disk"
                vbd.unplug \
                if vbd.allowed_operations.include?("unplug")
                vbd.vdi.destroy \
                if vbd.vdi.allowed_operations.include?("destroy")
              end
            end
            service.destroy_server( reference )
            true
          end

          def set_attribute(name, *val)
            data = service.set_attribute( 'VM', reference, name, *val )
            # Do not reload automatically for performance reasons
            # We can set multiple attributes at the same time and
            # then reload manually
            #reload
          end

          def refresh
            data = service.get_record( reference, 'VM' )
            merge_attributes( data )
            true
          end

          def tools_installed?
            !guest_metrics.nil?
          end

          def home_hypervisor
            service.hosts.first
          end

          def mac_address
            networks.first.MAC
          end

          def running?
            reload
            power_state == "Running"
          end

          def halted?
            reload
            power_state == "Halted"
          end

          # operations
          def start
            return false if running?
            service.start_server( reference )
            true
          end

          def save(params = {})
            requires :name
            nets = attributes[:networks] || []
            if params[:auto_start].nil?
              auto_start = true
            else
              auto_start = params[:auto_start]
            end
            if template_name
              attr = service.get_record(
                  service.create_server( name, template_name, nets, :auto_start => auto_start),
                  'VM'
              )
            else
              attr = service.get_record(
                  service.create_server_raw(attributes),
                  'VM'
              )
            end
            merge_attributes attr
            true
          end

          def reboot(stype = 'clean')
            service.reboot_server(reference, stype)
            true
          end

          def hard_reboot
            reboot 'hard'
          end

          def clean_reboot
            reboot 'clean'
          end

          def stop(stype = 'clean')
            return false if !running?
            service.shutdown_server( reference, stype )
            wait_for { power_state == 'Halted' }
            true
          end

          def hard_shutdown
            stop 'hard'
          end

          def clean_shutdown
            stop 'clean'
          end

          def provision
            service.provision_server reference
          end

          def snapshot(name)
            service.snapshot_server(reference, name)
          end

          def revert(snapshot_ref)
            service.snapshot_revert(snapshot_ref)
          end
        end
      end
    end
  end
end