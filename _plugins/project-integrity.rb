require "bibtex"

module Jekyll
  class ProjectIntegrityGenerator < Generator
    safe true
    priority :lowest

    def generate(site)
      errors = []
      projects_root = File.join(site.source, "projects")
      project_pages = site.pages.select { |page| page.data["project_id"] }

      project_ids = project_pages.map { |page| page.data["project_id"].to_s.strip }
      duplicate_ids = project_ids.group_by(&:itself).select { |_id, values| values.length > 1 }.keys
      duplicate_ids.each { |id| errors << "project_id '#{id}' is used by more than one project page" }

      project_pages.each do |page|
        project_id = page.data["project_id"].to_s.strip
        expected_source = File.join("projects", project_id, "index.md").tr("\\", "/")
        expected_url = "/projects/#{project_id}/"

        errors << "#{page.path}: project_id cannot be empty" if project_id.empty?
        errors << "#{page.path}: must be stored at #{expected_source}" unless page.path.tr("\\", "/") == expected_source
        errors << "#{page.path}: permalink must be #{expected_url}" unless page.data["permalink"] == expected_url

        validate_local_asset(site, page.path, project_id, page.data["cover"], "cover", errors)
        Array(page.data["gallery"]).each_with_index do |item, index|
          validate_local_asset(site, page.path, project_id, item["image"], "gallery item #{index + 1}", errors)
        end
        Array(page.data["gallery_sets"]).each_with_index do |gallery_set, set_index|
          items = Array(gallery_set["items"])
          errors << "#{page.path}: gallery set #{set_index + 1} has no items" if items.empty?
          items.each_with_index do |item, item_index|
            label = "gallery set #{set_index + 1}, item #{item_index + 1}"
            validate_local_asset(site, page.path, project_id, item["image"], "#{label} image", errors)
            validate_local_asset(site, page.path, project_id, item["thumbnail"], "#{label} thumbnail", errors) if item["thumbnail"]
          end
        end
        Array(page.data["videos"]).each_with_index do |video, index|
          unless video["youtube_id"] || video["embed_url"] || video["source"]
            errors << "#{page.path}: video #{index + 1} requires youtube_id, embed_url, or source"
          end
          validate_local_asset(site, page.path, project_id, video["source"], "video #{index + 1}", errors) if video["source"]
          validate_local_asset(site, page.path, project_id, video["poster"], "video #{index + 1} poster", errors) if video["poster"]
        end
        Array(page.data["pre_video_sections"]).each_with_index do |section, index|
          validate_local_asset(site, page.path, project_id, section["image"], "pre-video section #{index + 1} image", errors)
        end
        if page.data.dig("publication", "pdf")
          validate_local_asset(site, page.path, project_id, page.data.dig("publication", "pdf"), "publication PDF", errors)
        end
      end

      if Dir.exist?(projects_root)
        Dir.children(projects_root).sort.each do |directory_name|
          directory = File.join(projects_root, directory_name)
          next unless File.directory?(directory)

          index_file = File.join(directory, "index.md")
          errors << "projects/#{directory_name}/ is missing index.md" unless File.file?(index_file)
        end
      else
        errors << "projects/ directory does not exist"
      end

      bibliography_path = File.join(site.source, "_bibliography", site.config.dig("scholar", "bibliography"))
      if File.file?(bibliography_path)
        bibliography_source = File.read(bibliography_path, encoding: "UTF-8").sub(/\A---\s*\r?\n---\s*\r?\n/, "")
        BibTeX.parse(bibliography_source).entries.each_value do |entry|
          project_id = entry[:project].to_s.strip
          citation_key = entry.key.to_s
          if project_id.empty?
            errors << "bibliography entry '#{citation_key}' is missing the required project field"
          elsif !project_ids.include?(project_id)
            errors << "bibliography entry '#{citation_key}' references unknown project '#{project_id}'"
          end
        end
      else
        errors << "bibliography file not found: #{bibliography_path}"
      end

      return if errors.empty?

      message = "Project structure validation failed:\n- #{errors.join("\n- ")}"
      raise Jekyll::Errors::FatalException, message
    end

    private

    def validate_local_asset(site, page_path, project_id, asset_path, label, errors)
      if asset_path.to_s.strip.empty?
        errors << "#{page_path}: #{label} is missing"
        return
      end

      return if asset_path.include?("://")

      expected_prefix = "/projects/#{project_id}/assets/"
      unless asset_path.start_with?(expected_prefix)
        errors << "#{page_path}: #{label} must be inside #{expected_prefix}"
        return
      end

      source_path = File.join(site.source, asset_path.delete_prefix("/"))
      errors << "#{page_path}: #{label} file does not exist: #{asset_path}" unless File.file?(source_path)
    end
  end
end
