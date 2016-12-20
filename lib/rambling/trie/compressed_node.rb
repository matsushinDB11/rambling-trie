module Rambling
  module Trie
    # A representation of a node in an compressed Trie data structure.
    class CompressedNode < Rambling::Trie::Node
      # Always raises [InvalidOperation] when trying to add a branch to the
      # current trie node based on the word
      # @param [String] word the word to add the branch from.
      # @raise [InvalidOperation] if the trie is already compressed.
      def add word
        raise Rambling::Trie::InvalidOperation, 'Cannot add branch to compressed trie'
      end

      def partial_word? chars
        chars.empty? || has_partial_word?(chars)
      end

      def word? chars
        if chars.empty?
          terminal?
        else
          has_word? chars
        end
      end

      def scan chars
        closest_node(chars).to_a
      end

      def compressed?
        true
      end

      def letter= letter
        super
      end

      def terminal= terminal
        super
      end

      def children_tree= children_tree
        super
      end

      protected

      def closest_node chars
        if chars.empty?
          self
        else
          current_length = 0
          current_key, current_key_string = current_key chars.slice!(0)

          begin
            current_length += 1

            if current_key_string.length == current_length || chars.empty?
              return children_tree[current_key].closest_node chars
            end
          end while current_key_string[current_length] == chars.slice!(0)

          Rambling::Trie::MissingNode.new
        end
      end

      private

      def has_partial_word? chars
        current_length = 0
        current_key, current_key_string = current_key chars.slice!(0)

        begin
          current_length += 1

          if current_key_string.length == current_length || chars.empty?
            return children_tree[current_key].partial_word? chars
          end
        end while current_key_string[current_length] == chars.slice!(0)

        false
      end

      def has_word? chars
        current_key_string = ''

        while !chars.empty?
          current_key_string << chars.slice!(0)
          current_key = current_key_string.to_sym
          return children_tree[current_key].word? chars if children_tree.has_key? current_key
        end

        false
      end

      def current_key letter
        current_key_string = current_key = ''

        children_tree.keys.each do |key|
          key_string = key.to_s
          if key_string.start_with? letter
            current_key = key
            current_key_string = key_string
            break
          end
        end

        [current_key, current_key_string]
      end
    end
  end
end