# frozen_string_literal: true

module ResearchLog
  module AutoTags
    module_function

    TAG_REGEX = /(^|[\s\(\[\{>])#([A-Za-z0-9][\w-]*)\b/
    TODO_REGEX = /^\s*TODO:\s*(.+)$/i

    def process_site(site)
      documents = site.collections.each_value.flat_map(&:docs).select { |doc| markdown_document?(doc) }

      documents.each do |document|
        apply_to_document(document)
      end

      all_tags = Hash.new(0)
      documents.each do |document|
        Array(document.data["tags"]).uniq.each do |tag|
          all_tags[tag] += 1
        end
      end

      sorted = all_tags.sort.to_h
      site.data["all_tags"] = sorted
      site.config["all_tags"] = sorted
    end

    def apply_to_document(document)
      return unless markdown_document?(document)
      return if document.data["researchlog_auto_tags_processed"]

      original_content = document.content.to_s

      unless frontmatter_tags_present?(document)
        extracted_tags = original_content.scan(TAG_REGEX).map { |match| match[1].downcase }.uniq
        document.data["tags"] = extracted_tags
      else
        document.data["tags"] = normalize_tags(document.data["tags"])
      end

      extracted_todos = original_content.scan(TODO_REGEX).flatten.map(&:strip).reject(&:empty?)
      if blank_collection?(document.data["todos"])
        document.data["todos"] = extracted_todos
      end

      document.content = strip_hashtags(original_content)
      document.data["researchlog_auto_tags_processed"] = true
    end

    def strip_hashtags(content)
      stripped = content.gsub(TAG_REGEX) { Regexp.last_match(1).to_s }
      stripped.gsub(/^[ \t]+$/, "")
    end

    def frontmatter_tags_present?(document)
      tags = document.data["tags"]
      return false if tags.nil?
      return tags.any? if tags.respond_to?(:any?) && !tags.is_a?(String)

      !tags.to_s.strip.empty?
    end

    def normalize_tags(tags)
      if tags.is_a?(Array)
        tags.map { |tag| tag.to_s.strip.downcase }.reject(&:empty?).uniq
      else
        tags.to_s.split(/[,\s]+/).map(&:strip).reject(&:empty?).map(&:downcase).uniq
      end
    end

    def blank_collection?(value)
      return true if value.nil?
      return value.empty? if value.respond_to?(:empty?)

      false
    end

    def markdown_document?(document)
      extension = File.extname(document.path).downcase
      [".md", ".markdown", ".mkd", ".mdown"].include?(extension)
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  ResearchLog::AutoTags.process_site(site)
end

Jekyll::Hooks.register :documents, :pre_render do |document|
  ResearchLog::AutoTags.apply_to_document(document)
end
