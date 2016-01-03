# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Functions for checking the alignment of the `end` keyword.
    module EndKeywordAlignment
      include ConfigurableEnforcedStyle

      MSG = '`end` at %d, %d is not aligned with `%s` at %d, %d.'

      private

      def check_end_kw_in_node(node)
        check_end_kw_alignment(node, style => node.loc.keyword)
      end

      def check_end_kw_alignment(node, align_ranges)
        return if ignored_node?(node)

        end_loc = node.loc.end
        return unless end_loc # Discard modifier forms of if/while/until.

        matching = align_ranges.select do |_, range|
          range.line == end_loc.line || range.column == end_loc.column
        end

        if matching.key?(style)
          correct_style_detected
        else
          align_with = align_ranges[style]
          msg = format(MSG, end_loc.line, end_loc.column, align_with.source,
                       align_with.line, align_with.column)
          add_offense(node, end_loc, msg)
          style_detected(matching.keys)
        end
      end

      def parameter_name
        'AlignWith'
      end

      def variable_alignment?(whole_expression, rhs, end_alignment_style)
        end_alignment_style == :variable &&
          !line_break_before_keyword?(whole_expression, rhs)
      end

      def line_break_before_keyword?(whole_expression, rhs)
        rhs.loc.line > whole_expression.line
      end

      def align(node, align_to)
        source_buffer = node.source_range.source_buffer
        begin_pos = node.loc.end.begin_pos
        whitespace = Parser::Source::Range.new(source_buffer,
                                               begin_pos - node.loc.end.column,
                                               begin_pos)
        return false unless whitespace.source.strip.empty?

        column = if !align_to
                   0
                 elsif align_to.respond_to?(:loc)
                   align_to.source_range.column
                 else
                   align_to.column
                 end

        ->(corrector) { corrector.replace(whitespace, ' ' * column) }
      end
    end
  end
end
