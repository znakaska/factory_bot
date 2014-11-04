require 'active_support/core_ext/class/attribute'

module FactoryGirl
  # @api private
  class AttributesModuleGenerator
    class_attribute :foo
    self.foo = {}

    def self.cleanup
      self.foo = {}
    end

    def self.to_module(attributes)
      if FactoryGirl.configuration.module_caching
        if result = foo[attributes.hash]
          result
        else
          foo[attributes.hash] = new(attributes).to_module
        end
      else
        new(attributes).to_module
      end
    end

    def initialize(attributes)
      @attributes = attributes
    end

    def to_module
      mod = Module.new

      @attributes.each do |attribute|
        mod.send :define_method, attribute.name do
          if @cached_attributes.key?(attribute.name)
            @cached_attributes[attribute.name]
          else
            @cached_attributes[attribute.name] = instance_exec &attribute.to_proc
          end
        end
      end

      mod
    end
  end
end

