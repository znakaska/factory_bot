module FactoryBot
  # @api private
  class Definition
    attr_reader :defined_traits, :declarations, :name, :registered_enums

    def initialize(name, base_traits = [])
      @name = name
      @declarations = DeclarationList.new(name)
      @callbacks = []
      @defined_traits = Set.new
      @registered_enums = []
      @to_create = nil
      @base_traits = base_traits
      @additional_traits = []
      @constructor = nil
      @attributes = nil
      @compiled = false
      @expanded_enum_traits = false
    end

    delegate :declare_attribute, to: :declarations

    def attributes(*lookup)
      @attributes ||= generate_attributes(*lookup)
    end

    def generate_attributes(*lookup)
      AttributeList.new.tap do |attribute_list|
        attribute_lists = aggregate_from_traits(:attributes, *lookup) do
          declarations.attributes
        end
        attribute_lists.each do |attributes|
          attribute_list.apply_attributes attributes
        end
      end
    end

    def to_create(*lookup, &block)
      if block_given?
        @to_create = block
      else
        aggregate_from_traits(:to_create, *lookup) { @to_create }.last
      end
    end

    def constructor(*lookup)
      aggregate_from_traits(:constructor, *lookup) { @constructor }.last
    end

    def callbacks(*lookup)
      aggregate_from_traits(:callbacks, *lookup) { @callbacks }
    end

    def compile(klass = nil)
      unless @compiled
        expand_enum_traits(klass) unless klass.nil?

        declarations.attributes

        @compiled = true
      end
    end

    def overridable
      declarations.overridable
      self
    end

    def inherit_traits(new_traits)
      @base_traits += new_traits
    end

    def append_traits(new_traits)
      @additional_traits += new_traits
    end

    def add_callback(callback)
      @callbacks << callback
    end

    def skip_create
      @to_create = ->(instance) {}
    end

    def define_trait(trait)
      @defined_traits.add(trait)
    end

    def register_enum(enum)
      @registered_enums << enum
    end

    def define_constructor(&block)
      @constructor = block
    end

    def before(*names, &block)
      callback(*names.map { |name| "before_#{name}" }, &block)
    end

    def after(*names, &block)
      callback(*names.map { |name| "after_#{name}" }, &block)
    end

    def callback(*names, &block)
      names.each do |name|
        add_callback(Callback.new(name, block))
      end
    end

    def definition
      self
    end

    private

    def base_traits(*lookup)
      @base_traits.flat_map do |name|
        traits_by_name(name, *lookup)
      end
    rescue KeyError => error
      raise error_with_definition_name(error)
    end

    def error_with_definition_name(error)
      message = error.message
      message.insert(
        message.index("\nDid you mean?") || message.length,
        " referenced within \"#{name}\" definition"
      )

      error.class.new(message).tap do |new_error|
        new_error.set_backtrace(error.backtrace)
      end
    end

    def additional_traits(*lookup)
      @additional_traits.flat_map do |name|
        traits_by_name(name, *lookup)
      end
    end

    def traits_by_name(name, *lookup)
      traits = unique_by_definition(*lookup).flat_map do |object|
        object.defined_traits.find do |trait|
          trait.name == name.to_s
        end
      end.compact.uniq

      if traits.empty?
        traits << Internal.trait_by_name(name)
      end

      traits
    end

    def unique_by_definition(*objects)
      objects.uniq(&:definition)
    end

    def initialize_copy(source)
      super
      @attributes = nil
      @compiled = false
    end

    def aggregate_from_traits(method_name, *lookup)
      compile

      results = base_traits(*lookup).map do |trait|
        trait.send(method_name, *lookup)
      end

      results << yield if block_given?

      results += additional_traits(*lookup).map do |trait|
        trait.send(method_name, *lookup)
      end

      results.flatten.compact
    end

    def expand_enum_traits(klass)
      return if @expanded_enum_traits

      if automatically_register_defined_enums?(klass)
        automatically_register_defined_enums(klass)
      end

      registered_enums.each do |enum|
        traits = enum.build_traits(klass)
        traits.each { |trait| define_trait(trait) }
      end

      @expanded_enum_traits = true
    end

    def automatically_register_defined_enums(klass)
      klass.defined_enums.each_key { |name| register_enum(Enum.new(name)) }
    end

    def automatically_register_defined_enums?(klass)
      FactoryBot.automatically_define_enum_traits &&
        klass.respond_to?(:defined_enums)
    end
  end
end
