# frozen_string_literal: true

module ResearchLog
  module AutoTitle
    module_function

    def process_site(site)
      site.collections.each_value.flat_map(&:docs).each do |document|
        apply_to_document(document)
      end
    end

    def apply_to_document(document)
      return unless markdown_document?(document)
      return unless blank?(document.data["title"])

      basename = File.basename(document.path, File.extname(document.path))
      document.data["title"] = titleize_slug(basename)
    end

    def titleize_slug(slug)
      slug.tr("_-", " ").split.map { |word| normalize_word(word) }.join(" ")
    end

    def normalize_word(word)
      return word.upcase if word.match?(/\A[a-z]{1,5}\d*\z/) && word.length <= 4
      return word if word.empty?

      word[0].upcase + word[1..]
    end

    def blank?(value)
      value.nil? || value.to_s.strip.empty?
    end

    def markdown_document?(document)
      extension = File.extname(document.path).downcase
      [".md", ".markdown", ".mkd", ".mdown"].include?(extension)
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  ResearchLog::AutoTitle.process_site(site)
end

Jekyll::Hooks.register :documents, :pre_render do |document|
  ResearchLog::AutoTitle.apply_to_document(document)
end
