require 'active_support/core_ext/class/attribute'

module FactoryGirl
  # @api private
  class HashModuleGenerator
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

    def initialize(hash)
      @hash = hash
    end

    def to_module
      mod = Module.new

      @hash.each do |key, value|
        mod.send :define_method, key do
          if @cached_attributes.key?(key)
            @cached_attributes[key]
          else
            @cached_attributes[key] = value
          end
        end
      end

      mod
    end
  end
end
