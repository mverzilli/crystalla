module Crystalla
  module Spec
    class AllCloseExpectation(T)
      def initialize(@m : T)
      end

      def match(other)
        @target = other
        @m.all_close(other)
      end

      def failure_message
        "expected:\n#{@m.inspect}\n\ngot:\n#{@target.inspect}"
      end

      def negative_failure_message
        "expected not:\n#{@m.inspect}\n\ngot:\n#{@target.inspect}"
      end
    end

    module Expectations
      def be_all_close(value)
        Spec::AllCloseExpectation.new value
      end
    end
  end
end
