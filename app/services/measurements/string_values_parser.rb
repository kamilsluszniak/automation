# frozen_string_literal: true

module Measurements
  class StringValuesParser
    FLOAT_PATTERN = /\d+\.\d+/.freeze

    class << self
      def call(value)
        return value unless value.is_a? String

        if value.match(FLOAT_PATTERN)
          value.to_f
        else
          value.to_i
        end
      end
    end
  end
end
