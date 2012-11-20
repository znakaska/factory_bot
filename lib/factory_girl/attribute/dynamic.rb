module FactoryGirl
  class Attribute
    # @api private
    class Dynamic < Attribute
      def initialize(name, ignored, block)
        super(name, ignored)
        @block = block
      end

      def to_proc
        block = @block

        -> {
          value = case block.arity
          when 1 then block.call(self)
          when 2 then block.call(@instance, self)
          else instance_exec(&block)
          end
          raise SequenceAbuseError if FactoryGirl::Sequence === value
          value
        }
      end
    end
  end
end
