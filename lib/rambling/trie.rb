require 'forwardable'
%w{
  forwardable compression compressor inspector container enumerable
  invalid_operation readers serializers node missing_node compressed_node
  raw_node version
}.each do |file|
  require File.join('rambling', 'trie', file)
end

# General namespace for all Rambling gems.
module Rambling
  # Entry point for rambling-trie API.
  module Trie
    class << self
      # Creates a new Trie. Entry point for the Rambling::Trie API.
      # @param [String, nil] filepath the file to load the words from.
      # @param [Reader, nil] reader the file parser to get each word.
      # @return [Container] the trie just created.
      # @yield [Container] the trie just created.
      def create filepath = nil, reader = nil
        reader ||= default_reader

        Rambling::Trie::Container.new do |container|
          if filepath
            reader.each_word filepath do |word|
              container << word
            end
          end

          yield container if block_given?
        end
      end

      # Loads an existing Trie from disk into memory.
      # @param [String] filepath the file to load the words from.
      # @param [Serializer, nil] serializer the object responsible of loading the trie
      # from disk.
      # @return [Container] the trie just loaded.
      # @yield [Container] the trie just loaded.
      def load filepath, serializer = nil
        serializer ||= serializer filepath
        root = serializer.load filepath
        Rambling::Trie::Container.new root do |container|
          yield container if block_given?
        end
      end

      # Dumps an existing Trie from memory into disk.
      # @param [Container] trie the trie to dump into disk.
      # @param [String] filepath the file to dump to serialized trie into.
      # @param [Serializer, nil] serializer the object responsible of
      # serializing and dumping the trie into disk.
      def dump trie, filepath, serializer = nil
        serializer ||= serializer filepath
        serializer.dump trie, filepath
      end

      private

      def default_reader
        Rambling::Trie::Readers::PlainText.new
      end

      def default_serializer
        serializers[:marshal]
      end

      def serializer filepath
        format = File.extname filepath
        format.slice! 0
        serializers[format.to_sym] || default_serializer
      end

      def serializers
        {
          marshal: Rambling::Trie::Serializers::Marshal.new,
          yml: Rambling::Trie::Serializers::Yaml.new,
          yaml: Rambling::Trie::Serializers::Yaml.new,
        }
      end
    end
  end
end
