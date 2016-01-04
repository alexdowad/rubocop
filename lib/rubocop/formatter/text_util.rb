# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Formatter
    # Common logic for UI texts.
    module TextUtil
      module_function

      def pluralize(number, thing, options = {})
        if number == 0 && options[:no_for_zero]
          "no #{thing}s"
        elsif number == 1
          "#{number} #{thing}"
        else
          "#{number} #{thing}s"
        end
      end
    end
  end
end
