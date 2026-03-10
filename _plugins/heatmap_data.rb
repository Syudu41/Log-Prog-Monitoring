# frozen_string_literal: true

require "date"
require "time"
require_relative "git_timestamps"

module ResearchLog
  module HeatmapData
    module_function

    def process_site(site)
      daily_counts = Hash.new(0)
      documents = site.collections.each_value.flat_map(&:docs).select { |doc| markdown_document?(doc) }

      documents.each do |document|
        created_time = created_time_for(document, site)
        next if created_time.nil?

        key = created_time.utc.strftime("%Y-%m-%d")
        daily_counts[key] += 1
      end

      sorted_counts = daily_counts.sort.to_h
      site.data["heatmap"] = {
        "daily" => sorted_counts,
        "stats" => {
          "total_entries" => documents.length,
          "active_days_this_month" => active_days_this_month(sorted_counts),
          "current_streak" => current_streak(sorted_counts)
        }
      }
    end

    def created_time_for(document, site)
      return parse_time(document.data["date_created"]) if document.data.key?("date_created")

      relative_path = ResearchLog::GitTimestamps.to_relative_path(document.path, site.source)
      dates = ResearchLog::GitTimestamps.fetch(site.source, relative_path)
      parse_time(dates["created_iso"]) || fallback_mtime(document.path)
    rescue StandardError
      fallback_mtime(document.path)
    end

    def active_days_this_month(counts)
      prefix = Date.today.strftime("%Y-%m-")
      counts.count { |day, count| day.start_with?(prefix) && count.to_i.positive? }
    end

    def current_streak(counts)
      streak = 0
      day = Date.today

      loop do
        key = day.strftime("%Y-%m-%d")
        break unless counts[key].to_i.positive?

        streak += 1
        day -= 1
      end

      streak
    end

    def parse_time(value)
      return value if value.is_a?(Time)
      return nil if value.nil? || value.to_s.strip.empty?

      Time.parse(value.to_s)
    rescue StandardError
      nil
    end

    def fallback_mtime(path)
      File.exist?(path) ? File.mtime(path).utc : Time.now.utc
    rescue StandardError
      Time.now.utc
    end

    def markdown_document?(document)
      extension = File.extname(document.path).downcase
      [".md", ".markdown", ".mkd", ".mdown"].include?(extension)
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  ResearchLog::HeatmapData.process_site(site)
end
