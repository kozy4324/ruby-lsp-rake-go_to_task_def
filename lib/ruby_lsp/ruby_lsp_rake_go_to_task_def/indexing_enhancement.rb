# frozen_string_literal: true

module RubyLsp
  module RakeGoToTaskDef
    class IndexingEnhancement < RubyIndexer::Enhancement
      def on_call_node_enter(node)
        return unless @listener.current_owner.nil?
        return unless node.name == :task

        arguments = node.arguments&.arguments
        return unless arguments

        arg = arguments.first
        name = case arg
               when Prism::StringNode
                 arg.content
               when Prism::SymbolNode
                 arg.value
               when Prism::KeywordHashNode
                 case arg.child_nodes.first
                 when Prism::AssocNode
                   case arg.child_nodes.first.key
                   when Prism::StringNode
                     arg.child_nodes.first.key.content
                   when Prism::SymbolNode
                     arg.child_nodes.first.key.value
                   end
                 end
               end

        return if name.nil?

        location = node.location
        @listener.add_method(
          "task_#{name}",
          location,
          nil
        )
      end

      def on_call_node_leave(node); end
    end
  end
end
