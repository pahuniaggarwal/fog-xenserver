require 'minitest_helper'

describe Fog::Compute::XenServer::Models::Vbd do
  let(:vbd_class) do
    class Fog::Compute::XenServer::Models::Vbd
      def self.read_identity
        instance_variable_get('@identity')
      end
    end
    Fog::Compute::XenServer::Models::Vbd
  end

  it 'should return the unique id' do
    vbd_class.read_identity.must_equal(:reference)
  end

  it 'should have 23 attributes' do
    vbd_class.attributes.must_equal([ :reference,
                                      :allowed_operations,
                                      :bootable,
                                      :currently_attached,
                                      :current_operations,
                                      :device,
                                      :empty,
                                      :mode,
                                      :other_config,
                                      :qos_supported_algorithms,
                                      :qos_algorithm_params,
                                      :qos_algorithm_type,
                                      :runtime_properties,
                                      :status_code,
                                      :status_detail,
                                      :storage_lock,
                                      :type,
                                      :unpluggable,
                                      :userdevice,
                                      :uuid,
                                      :__metrics,
                                      :__vdi,
                                      :__vm ])
  end

  it 'should have 5 aliases' do
    vbd_class.aliases.must_equal({ :VDI => :__vdi,
                                   :vdi => :__vdi,
                                   :VM => :__vm,
                                   :vm => :__vm,
                                   :metrics => :__metrics })
  end
end