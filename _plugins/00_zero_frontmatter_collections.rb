# frozen_string_literal: true

require "set"

module ResearchLog
  module ZeroFrontmatterCollections
    module_function

    MARKDOWN_EXTENSIONS = [".md", ".markdown", ".mkd", ".mdown"].freeze

    def process_site(site)
      converted_paths = Set.new

      site.collections.each_value do |collection|
        next if collection.label == "posts"

        convert_collection_files(site, collection, converted_paths)
      end

      remove_from_static_outputs(site, converted_paths)
    end

    def convert_collection_files(site, collection, converted_paths)
      collection.filtered_entries.each do |relative_entry|
        full_path = collection.collection_dir(relative_entry)
        next unless File.file?(full_path)
        next unless markdown_file?(full_path)
        next if Jekyll::Utils.has_yaml_header?(full_path)
        next if document_already_loaded?(collection, full_path)

        document = Jekyll::Document.new(full_path, :site => site, :collection => collection)
        document.read

        if site.unpublished || document.published?
          collection.docs << document
          converted_paths << File.expand_path(full_path)
        end
      end

      collection.docs.sort!
    end

    def remove_from_static_outputs(site, converted_paths)
      return if converted_paths.empty?

      site.static_files.reject! { |static_file| converted_paths.include?(File.expand_path(static_file.path)) }
      site.collections.each_value do |collection|
        collection.files.reject! { |static_file| converted_paths.include?(File.expand_path(static_file.path)) }
      end
    end

    def document_already_loaded?(collection, full_path)
      collection.docs.any? { |doc| File.expand_path(doc.path) == File.expand_path(full_path) }
    end

    def markdown_file?(path)
      MARKDOWN_EXTENSIONS.include?(File.extname(path).downcase)
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  ResearchLog::ZeroFrontmatterCollections.process_site(site)
end
