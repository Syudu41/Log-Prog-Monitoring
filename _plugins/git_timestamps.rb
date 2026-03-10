# frozen_string_literal: true

require "open3"
require "pathname"
require "time"

module ResearchLog
  module GitTimestamps
    module_function

    @cache = {}
    @warned_shallow = false

    def process_site(site)
      warn_if_shallow(site.source)
      collection_documents(site).each do |document|
        apply_to_document(document)
      end
    end

    def apply_to_document(document)
      return unless markdown_document?(document)

      source = document.site.source
      relative_path = relative_path_for(document, source)
      dates = fetch(source, relative_path)

      fallback_time = file_mtime(document.path, source)
      created_time = parse_time(dates["created_iso"]) || parse_time(document.data["date_created"]) || parse_time(document.data["date"]) || fallback_time
      modified_time = parse_time(dates["modified_iso"]) || parse_time(document.data["date_modified"]) || created_time || fallback_time

      document.data["date_created"] ||= created_time
      document.data["date_modified"] ||= modified_time
      document.data["date"] ||= created_time
      document.data["last_modified_at"] ||= modified_time
    end

    def fetch(source, relative_path)
      return @cache[relative_path] if @cache.key?(relative_path)

      created_lines = run_git(source, ["log", "--follow", "--format=%aI", "--diff-filter=A", "--", relative_path])
      modified_line = run_git(source, ["log", "-1", "--format=%aI", "--", relative_path])

      created_iso = created_lines.to_s.lines.map(&:strip).reject(&:empty?).last
      modified_iso = modified_line.to_s.lines.map(&:strip).reject(&:empty?).first

      @cache[relative_path] = {
        "created_iso" => created_iso,
        "modified_iso" => modified_iso
      }
    end

    def markdown_document?(document)
      extension = File.extname(document.path).downcase
      [".md", ".markdown", ".mkd", ".mdown"].include?(extension)
    end

    def collection_documents(site)
      site.collections.each_value.flat_map(&:docs)
    end

    def relative_path_for(document, source)
      raw = document.respond_to?(:relative_path) ? document.relative_path : document.path
      to_relative_path(raw, source)
    end

    def to_relative_path(raw_path, source)
      return "" if raw_path.nil? || raw_path.empty?

      path = Pathname.new(raw_path)
      if path.absolute?
        path.relative_path_from(Pathname.new(source)).to_s
      else
        raw_path.sub(%r{\A\./}, "")
      end
    rescue StandardError
      raw_path
    end

    def parse_time(value)
      return value if value.is_a?(Time)
      return nil if value.nil? || value.to_s.strip.empty?

      Time.parse(value.to_s)
    rescue StandardError
      nil
    end

    def file_mtime(raw_path, source)
      full_path = if Pathname.new(raw_path).absolute?
                    raw_path
                  else
                    File.join(source, raw_path)
                  end

      File.exist?(full_path) ? File.mtime(full_path).utc : Time.now.utc
    rescue StandardError
      Time.now.utc
    end

    def run_git(source, args)
      stdout, status = Open3.capture2e("git", *args, chdir: source)
      return stdout if status.success?

      nil
    rescue StandardError
      nil
    end

    def warn_if_shallow(source)
      return if @warned_shallow

      output = run_git(source, ["rev-parse", "--is-shallow-repository"])
      if output.to_s.strip == "true"
        Jekyll.logger.warn("ResearchLog:", "Shallow git history detected. Date extraction may be incomplete.")
      end

      @warned_shallow = true
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  ResearchLog::GitTimestamps.process_site(site)
end

Jekyll::Hooks.register :documents, :pre_render do |document|
  ResearchLog::GitTimestamps.apply_to_document(document)
end
