# Changelog

## 0.5.0 - 2026-07-17

- Made same-topic Chrome reuse fail-closed: later packets must positively prove attachment to the recorded browser endpoint and exact ChatGPT tab before a live run.
- Split first-run browser ownership (`--browser-port` plus `--browser-keep-browser`) from later attach commands (`--browser-attach-running`, `--remote-chrome`, and `--browser-tab`).
- Removed the invalid Oracle 0.16 `--browser-attach-running` plus `--browser-keep-browser` example and documented the launch-only/attach-only flag boundary.
- Clarified that browser `--followup` restores conversation configuration but does not guarantee the same Chrome process or tab.
- Added endpoint, exact tab ref, reuse-preflight, and new-window fields to the local thread and ledger contracts; opening a replacement window now requires explicit user approval.

## 0.4.0 - 2026-07-17

- Changed the preferred browser architect target to ChatGPT `Pro`, currently GPT-5.6 Sol Pro on eligible accounts, using Oracle's `gpt-5-pro` alias.
- Added separate, explicit routes for GPT-5.6 Sol in ChatGPT browser mode and the OpenAI API with `gpt-5.6-sol`.
- Required Oracle 0.16.0 or newer before using GPT-5.6 aliases and added dry-run checks for detecting older-model normalization.
- Replaced GPT-5.5-centric CLI and MCP examples with explicit GPT-5.6 Pro/Sol model selection and stronger model-evidence recording.
- Clarified that `gpt-5.6-sol-pro` is not an API model id and that a `Pro` picker label alone is not server-generation proof.

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
