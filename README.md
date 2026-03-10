# ResearchLog

ResearchLog is a keyboard-first personal PhD research journal built in plain HTML, CSS, and JavaScript.

No frameworks, no dependencies, no build step. Open one file in your browser and start logging.

## What It Is

ResearchLog is designed for:

- experiment notes
- paper and reading insights
- advisor meeting notes
- daily research progress
- goal and todo tracking

The command palette is the primary workflow:

- Press Cmd/Ctrl+K anywhere
- Type slash commands
- Manage the app without touching the mouse

## Project Structure

- index.html: Entire app in one file (UI, styles, logic)
- README.md: This guide
- sample-data.json: Importable test dataset

## Quick Start

1. Open index.html in Chrome or Firefox.
2. Press Cmd/Ctrl+K.
3. Run:

```text
/log Finished reading transformer appendix #research #reading
```

4. Create a todo:

```text
/todo Write lit review summary for advisor #paper @friday
```

## Commands

- /log <text>: Add a timestamped research log entry
- /todo <text>: Add a goal/todo item
- /done <id or text>: Mark a todo complete
- /search <query>: Full-text search entries and todos
- /tag <tagname>: Filter by tag
- /export: Download JSON backup
- /import: Import and merge backup JSON
- /today: Jump to today's group
- /flashback: Show entries from 1w, 2w, 1m, 3m, 6m lookbacks
- /help: Show all commands

## Data Storage

- localStorage key: researchlog_entries
- localStorage key: researchlog_settings

Export uses JSON backups named like:

```text
researchlog-backup-YYYY-MM-DD.json
```

## Sample Data

Use sample-data.json to test:

1. Open the app
2. Press Cmd/Ctrl+K
3. Run /import
4. Select sample-data.json

This dataset includes:

- 20+ logs and todos
- varied tags and context markers
- multiple dates for heatmap intensity
- entries that support flashback lookback windows

## Screenshot

Add screenshot here:

```text
docs/screenshot-placeholder.png
```

## Notes

Current version is v1.0.0 and intentionally excludes:

- markdown rendering
- entry editing/deletion
- theme toggle
- stats dashboard
- pinning entries

These are planned as hooks for v1.1.
