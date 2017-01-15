module Performance
  class LookupsWordTask
    def initialize iterations = 200_000
      @iterations = iterations
    end

    def name
      'lookups:word'
    end

    def execute performer_class, trie
      performer = performer_class.new filename trie
      performer.perform iterations, params do |word|
        trie.word? word
      end
    end

    private

    attr_reader :iterations

    def params
      %w(hi help beautiful impressionism anthropological)
    end

    def filename trie
      "#{trie.compressed? ? 'compressed' : 'raw'}-lookups-word"
    end
  end
end
