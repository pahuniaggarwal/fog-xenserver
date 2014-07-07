module Fog
  module Compute
    class XenServer
      module Models
        class Role < Fog::Model
          # API Reference here:
          # http://docs.vmd.citrix.com/XenServer/6.2.0/1.0/en_gb/api/?c=role

          identity :reference

          attribute :description,         :aliases => :name_description
          attribute :name,                :aliases => :name_label
          attribute :uuid

          has_many  :subroles,  :roles
        end
      end
    end
  end
end