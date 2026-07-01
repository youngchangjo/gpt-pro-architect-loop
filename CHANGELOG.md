# Changelog

## 0.3.1 - 2026-07-01

- Added an explicit browser reuse policy for Oracle/ChatGPT browser consults.
- Prefer saved conversation URLs, Oracle sessions, `--followup`, saved browser tab refs, `--browser-attach-running`, or user-provided `--remote-chrome` before opening a fresh Chrome window.
- Clarified that MCP consult can still be used for normal runs, but CLI is preferred when a same-topic browser surface must be reused and MCP does not expose attach-running/tab fields.
- Required reuse attempts and any browser automation limitations to be recorded in `thread.md` and `ledger.md`.

## 0.3.0 - 2026-06-28

- Added same-topic continuity rules so one command/topic reuses the same architect conversation by default.
- Added Oracle archive/keep-browser guidance for active reviews: `browserArchive: "never"` and `browserKeepBrowser: true`.
- Added CLI and MCP follow-up guidance for challenge/final-decision passes in one ChatGPT conversation.
- Expanded `thread.md` and `ledger.md` fields for topic id, conversation URL, session ids, archive policy, continuation status, and model evidence.
- Added local preflight checks for stale packet references, missing paths, placeholders, oversized packets, and weak implementation plans.
- Split asset/image generation from architect approval so failed image output is not treated as review failure.
- Renamed general documentation wording to continuity notes while preserving legacy paths when a repo already uses them.

## 0.2.1 - 2026-06-27

- Clarified that Oracle is optional and the manual ChatGPT browser path remains valid.
- Added README flow charts for the decision flow and artifact flow.
- Split required core gate responsibilities from optional transport choices.
- Updated packet workflow wording so Oracle dry-runs apply only when Oracle is used.

## 0.2.0 - 2026-06-27

- Added Oracle-first transport order: MCP, CLI, render/copy, manual browser fallback.
- Added Oracle MCP `consult` guidance with `chatgpt-pro-heavy`, `dryRun`, and explicit follow-up handling.
- Added Oracle CLI dry-run, files-report, render/copy, status, and session recovery guidance.
- Preserved the original approval, redaction, packet, response, ledger, and continuity-note rules.
- Added repository-level README, install script, MCP examples, and version file.

## 0.1.0 - 2026-06-26

- Initial dedicated ChatGPT Pro architect loop.
- Defined packet/response/ledger artifacts.
- Defined `APPROVE`, `REVISE`, and `BLOCK` response contract.
- Required explicit external-transmission approval and local canonical memory.
