module HamlLint
  # Checks for unnecessary outputting of strings in Ruby script tags.
  #
  # For example, the following two code snippets are equivalent, but the latter
  # is more concise (and thus preferred):
  #
  #   %tag= "Some #{expression}"
  #   %tag Some #{expression}
  class Linter::UnnecessaryStringOutput < Linter
    include LinterRegistry

    MESSAGE = '`= "..."` should be rewritten as `...`'

    def visit_tag(node)
      if tag_has_inline_script?(node) && inline_content_is_string?(node)
        add_lint(node, MESSAGE)
      end
    end

    def visit_script(node)
      # Some script nodes created by the HAML parser aren't actually script
      # nodes declared via the `=` marker. Check for it.
      return if node.source_code !~ /\s*=/

      if outputs_string_literal?(node)
        add_lint(node, MESSAGE)
      end
    end

    private

    def outputs_string_literal?(script_node)
      %w[' "].include?(script_node.script.lstrip[0])
    end
  end
end
