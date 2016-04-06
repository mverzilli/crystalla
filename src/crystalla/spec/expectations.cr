module Crystalla
  module Spec
    class AllCloseExpectation(T)
      def initialize(@m : T, @absolute_tolerance, @relative_tolerance)
      end

      def match(other)
        @target = other
        @m.all_close(other, @absolute_tolerance, @relative_tolerance)
      end

      def failure_message(m)
        "expected:\n#{m.inspect}\n\ngot:\n#{@target.inspect}"
      end

      def negative_failure_message(m)
        "expected not:\n#{m.inspect}\n\ngot:\n#{@target.inspect}"
      end
    end

    module Expectations
      def be_all_close(value)
        Spec::AllCloseExpectation.new value, nil, nil
      end

      def be_all_close(value, absolute_tolerance, relative_tolerance)
        Spec::AllCloseExpectation.new value, absolute_tolerance, relative_tolerance
      end
    end
  end
end
