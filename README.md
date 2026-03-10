# ResearchLog

ResearchLog is a git-native open research notebook built with Jekyll.

Core workflow:
- Write markdown in collection folders.
- Commit and push.
- GitHub Actions builds and deploys to GitHub Pages.

No frontmatter is required for normal use. Titles, tags, and timestamps are auto-derived.

## Features

- Zero-frontmatter publishing.
- Git-powered created and modified timestamps.
- Automatic hashtag and TODO extraction.
- Homepage contribution heatmap for the last 6 months.
- Cmd/Ctrl+K client-side search from prebuilt JSON.
- Tag index with per-tag entry listings.
- Category navigation backed by collection folders.

## Local Setup

Prerequisites:
- Ruby 3.2+
- Bundler

Install dependencies:

bundle install

Run locally:

bundle exec jekyll serve

Then open http://127.0.0.1:4000/researchlog/.

## Writing Entries

Create markdown files in any category collection folder:

- _research/
- _ideas/
- _experiments/
- _meetings/
- _reading/

Example entry format (no frontmatter):

Finished reading an important paper and extracted key observations.

#reading #papers #transformers

TODO: Re-run ablation with fixed seed.

What gets inferred automatically:
- title from filename
- category from folder name
- tags from inline hashtags
- todos from lines starting with TODO:
- date_created from first git commit for that file
- date_modified from latest git commit for that file

Frontmatter is optional and can override defaults, for example title or tags.

## Add a New Category

1. Create a folder with underscore prefix, for example _field-notes/.
2. Add the collection entry in _config.yml.
3. Add a matching default layout scope in _config.yml.
4. Create a page at root with layout category and collection_name set.

## Deployment

Push to main to trigger .github/workflows/deploy.yml.

Important:
- actions/checkout uses fetch-depth: 0 so git history is complete.
- Full history is required for accurate created and modified timestamps.

## Project Structure

- _plugins/: build-time metadata extraction and aggregation
- _layouts/ and _includes/: page rendering templates
- assets/css/style.css: full site styling
- assets/js/search.js: search overlay and ranking
- assets/js/heatmap.js: GitHub-style heatmap rendering
- search.json: generated client-side search index
