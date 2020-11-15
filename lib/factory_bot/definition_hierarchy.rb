module FactoryBot
  class DefinitionHierarchy
    delegate :callbacks, :constructor, :to_create, to: Internal

    def self.build_from_factory(factory)
      lookup = [factory, *factory.ancestors].reverse

      to_create = factory.definition.to_create(*lookup)
      build_to_create(&to_create)

      constructor = factory.definition.constructor(*lookup)
      build_constructor(&constructor)

      callbacks = factory.definition.callbacks(*lookup)
      add_callbacks(callbacks)
    end

    def self.add_callbacks(callbacks)
      if callbacks.any?
        define_method :callbacks do
          super() + callbacks
        end
      end
    end
    private_class_method :add_callbacks

    def self.build_constructor(&block)
      if block
        define_method(:constructor) do
          block
        end
      end
    end
    private_class_method :build_constructor

    def self.build_to_create(&block)
      if block
        define_method(:to_create) do
          block
        end
      end
    end
    private_class_method :build_to_create
  end
end
