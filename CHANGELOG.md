# Changelog

## 0.2.1 - 2026-06-27

- Clarified that Oracle is optional and the manual ChatGPT browser path remains valid.
- Added README flow charts for the decision flow and artifact flow.
- Split required core gate responsibilities from optional transport choices.
- Updated packet workflow wording so Oracle dry-runs apply only when Oracle is used.

## 0.2.0 - 2026-06-27

- Added Oracle-first transport order: MCP, CLI, render/copy, manual browser fallback.
- Added Oracle MCP `consult` guidance with `chatgpt-pro-heavy`, `dryRun`, and explicit follow-up handling.
- Added Oracle CLI dry-run, files-report, render/copy, status, and session recovery guidance.
- Preserved the original approval, redaction, packet, response, ledger, and handoff rules.
- Added repository-level README, install script, MCP examples, and version file.

## 0.1.0 - 2026-06-26

- Initial dedicated ChatGPT Pro architect loop.
- Defined packet/response/ledger artifacts.
- Defined `APPROVE`, `REVISE`, and `BLOCK` response contract.
- Required explicit external-transmission approval and local canonical memory.
