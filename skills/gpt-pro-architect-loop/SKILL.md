---
name: gpt-pro-architect-loop
description: Use when the user wants ChatGPT Pro or Oracle to act as an external architect, reviewer, or decision gate for Codex work across repo implementation rounds.
version: 0.2.0
---

# GPT Pro Architect Loop

Use a dedicated external architect loop while Codex remains the builder with local repo access. The local repo is the canonical memory; the external model is an advisory reviewer fed by bounded, redacted packets.

Prefer Oracle when it is installed because it handles file bundling, dry runs, sessions, follow-ups, and browser automation more reliably than manual ChatGPT.com operation. Keep the original browser path as the fallback.

## Transport Priority

Use the first available path that fits the user's approval scope:

1. Oracle MCP `consult` when the `oracle` MCP server is available in the current Codex session.
2. Oracle CLI `oracle` when the CLI is installed but MCP is not available in this session.
3. Oracle render/copy mode when automation is blocked but a prepared bundle is still useful.
4. Manual ChatGPT.com browser thread as the final fallback.

Do not let a stronger transport weaken the safety rules. Oracle is a delivery layer, not the source of truth.

## Non-Negotiables

- Never send secrets, credentials, `.env` values, private keys, tokens, personal contact/payment identifiers, or unrelated user data.
- Treat every packet, upload, paste, screenshot, copied diff, Oracle bundle, Oracle MCP request, and ChatGPT.com browser action as external transmission.
- Get explicit user approval before the first transmission for a task. Ask again before sending new sensitive categories, uploads, screenshots, personal files, a different destination, or a different engine.
- Do not inspect Codex internal browser or Chrome cookies, local storage, passwords, session stores, or account internals.
- The architect cannot approve commits, pushes, releases, purchases, account changes, or permission changes by itself. `APPROVE` is an advisory gate; the user remains the authority.
- The local ledger and `docs/HANDOFF.md` or `.codex/gpt-pro-architect/HANDOFF.md` are canonical memory. Do not rely on ChatGPT, Oracle sessions, or browser history as the source of truth.
- If Oracle session state conflicts with the local ledger, trust the local ledger and record the discrepancy before continuing.

## When Not To Use

- The user requested analysis-only and did not ask for an external architect/reviewer.
- The repo contains data that cannot be sent externally and cannot be safely summarized.
- The task can be handled with local tests, local review, or built-in Codex tools without an external architect.
- The user needs a guaranteed API-stable integration. ChatGPT.com and browser automation are best-effort.

## Setup

1. Find the repo root and read applicable `AGENTS.md` files.
2. Create `.codex/gpt-pro-architect/` for local state if it does not exist.
3. Use `docs/HANDOFF.md` when the repo already has it or the user requested repo-visible memory. Otherwise use `.codex/gpt-pro-architect/HANDOFF.md`.
4. Store external thread/session metadata in `.codex/gpt-pro-architect/thread.md`:

```md
# GPT Pro Architect Thread

- destination:
- transport: Oracle MCP | Oracle CLI | Oracle render/copy | ChatGPT browser
- model target: ChatGPT Pro / Pro Extended or Oracle preset
- thread url:
- oracle session id:
- created:
- last packet:
- approval scope:
```

5. Check local transport availability:

```bash
command -v oracle
oracle --version
oracle status --hours 24 --limit 20
```

6. If Oracle MCP is configured for Codex, prefer it. If it is not available in the current session, use the CLI and note that MCP may require a new Codex session after config changes.

## Oracle MCP Flow

Use this path only when the `oracle` MCP server is available as a callable tool in the current session.

1. Build the packet locally first; save it under `.codex/gpt-pro-architect/packets/packet-<N>.md`.
2. Run an MCP dry run before the real consult:

```json
{
  "preset": "chatgpt-pro-heavy",
  "prompt": "<Architect contract + decision question>",
  "files": [
    ".codex/gpt-pro-architect/packets/packet-<N>.md"
  ],
  "slug": "architect-packet-<N>",
  "dryRun": true
}
```

3. Review the resolved files and destination. If the data categories match the user's approval scope, run the same consult with `dryRun: false`.
4. Use `preset: "chatgpt-pro-heavy"` for ChatGPT Pro browser mode. Use `engine: "browser"` explicitly if routing is ambiguous.
5. For architecture decisions that benefit from a challenge pass, use `browserFollowUps` such as:

```json
[
  "Challenge your previous recommendation. Keep the scope tight.",
  "Return the final APPROVE, REVISE, or BLOCK decision in the required format."
]
```

6. If a long browser consult appears stalled, check Oracle sessions before retrying. Do not start duplicate runs until `oracle status` or MCP `sessions` shows the prior run is finished or unrecoverable.

## Oracle CLI Flow

Use this when Oracle is installed but MCP is not available in the current Codex session.

1. Save the packet first.
2. Preview the resolved bundle:

```bash
oracle \
  --engine browser \
  --model gpt-5.5-pro \
  --browser-model-strategy current \
  --browser-attachments auto \
  --files-report \
  --dry-run summary \
  --slug architect-packet-<N> \
  --prompt "Run the GPT Pro Architect review. Use the attached packet and required response format." \
  --file .codex/gpt-pro-architect/packets/packet-<N>.md
```

3. If the dry run is clean and the user has approved the destination/data categories, run the live command without `--dry-run`.
4. For manual review or blocked browser automation, render and copy the exact bundle:

```bash
oracle \
  --render \
  --copy-markdown \
  --prompt "Run the GPT Pro Architect review. Use the attached packet and required response format." \
  --file .codex/gpt-pro-architect/packets/packet-<N>.md
```

5. If Oracle reports an existing matching/running session, reattach instead of rerunning:

```bash
oracle status --hours 72 --limit 50
oracle session <session-id-or-slug> --render
```

6. Record Oracle session id, slug, model, engine, and any browser automation limitation in `thread.md` and `ledger.md`.

## Manual Browser Fallback

Use this only when Oracle is not installed, Oracle is blocked, or the user explicitly asks for the manual path.

1. Open or create one dedicated ChatGPT.com thread in the Codex internal browser first. If that is not possible, fall back to Chrome, then Computer Use.
2. In the current visible model picker, choose the best available Pro/Extended option. If no suitable Pro option is visible, stop and ask the user which model to use.
3. Pin the architect contract in the first message or re-send it when the thread has drifted.
4. Save the resulting thread URL in `.codex/gpt-pro-architect/thread.md`.
5. Before transmitting a packet, tell the user the destination and data categories, then request approval unless the current task already has explicit approval for those exact categories.

Do not automate login challenges, CAPTCHA, account security prompts, payment prompts, or permission changes. Hand off to the user.

## Architect Contract Prompt

Send this as the first message in the dedicated thread or include it at the top of the Oracle prompt:

```md
You are the GPT Pro Architect for this Codex session.

Role:
- You do not implement code.
- You judge plans, specs, diffs, tests, risks, and next steps.
- You are allowed to be blunt and reject weak work.
- You must keep scope tight and call out overengineering.

Required output:
- Decision: APPROVE, REVISE, or BLOCK.
- One-paragraph rationale.
- Required changes, if any.
- Risks or missing evidence.
- Next packet request.

Rules:
- Do not ask for the whole repo unless a smaller packet is insufficient.
- Do not invent facts outside the packet.
- Treat local ledger and HANDOFF summaries as canonical.
- If evidence is missing, say exactly what evidence would change your decision.
- Prefer interface/schema contracts before implementation details.
```

## Architect Packet

Each round sends an incremental architect packet. Keep it small enough to review, usually under 12k-20k characters unless the user approved a file upload.

```md
# Architect Packet <N>

## Metadata
- repo:
- branch:
- commit:
- packet date:
- previous packet:
- current goal:

## Approval Scope
- destination:
- transport:
- data categories: repo summary, selected diffs, test output, handoff notes
- excluded: secrets, `.env`, credentials, unrelated personal data

## Canonical Memory
<Relevant excerpt from docs/HANDOFF.md or .codex/gpt-pro-architect/HANDOFF.md>

## Since Last Packet
<Incremental changes only: files touched, decisions made, unresolved questions>

## Current Diff Summary
<git status, git diff --stat, and focused hunks or summaries>

## Evidence
<Commands run, test results, screenshots described, benchmark numbers, failures>

## Decision Needed
<The exact architecture/review question Codex wants answered>

## Required Response Format
Decision: APPROVE | REVISE | BLOCK
Rationale:
Required changes:
Risks/missing evidence:
Next packet request:
```

## Local Collection Rules

Useful local facts:

```bash
git status --short
git branch --show-current
git rev-parse --short HEAD
git diff --stat
git diff --check
```

Collect focused diffs and test output, not the whole repo. Before sending, do a redaction pass:

- Exclude `.env*`, keychains, credentials, API keys, tokens, private keys, customer data, personal identifiers, and generated artifacts that do not affect the decision.
- Replace suspicious values with `[REDACTED]`.
- If a secret-like line is needed for architecture, describe the shape only, not the value.
- If redaction is uncertain, do not send. Ask the user.
- Use Oracle `--dry-run summary` or MCP `dryRun: true` before live transmission when the file set changed.
- Use Oracle `--files-report` when attaching more than one packet or any source file.

## Ledger

After every architect exchange:

1. Save the outgoing packet as `.codex/gpt-pro-architect/packets/packet-<N>.md`.
2. Save the architect response as `.codex/gpt-pro-architect/responses/response-<N>.md`.
3. Append a short entry to `.codex/gpt-pro-architect/ledger.md`:

```md
## Round <N> - <date>
- sent:
- transport:
- oracle session:
- architect decision:
- accepted actions:
- rejected actions:
- user decision:
- next:
```

4. Update `docs/HANDOFF.md` or `.codex/gpt-pro-architect/HANDOFF.md` with only durable decisions:
   - what was built
   - why the approach was chosen
   - unresolved risks
   - next packet target

## Acting On Responses

- `APPROVE`: Codex may proceed to the next local implementation or verification step if it also fits the user's instructions. Do not merge, push, release, or make external changes unless the user approved that separately.
- `REVISE`: convert the architect's objections into a local checklist. Implement only items that are in scope and technically grounded.
- `BLOCK`: stop the implementation path and gather the named evidence or ask the user for a decision.

If the architect proposes broad rewrites, new dependencies, or speculative architecture, push back in the next packet and ask for the minimum viable change.

## Completion Checklist

Before reporting back:

- Local canonical memory exists and was updated.
- Packet and response files are saved.
- The latest architect decision is summarized.
- User approval scope is recorded.
- No known secrets or unrelated personal data were transmitted.
- Oracle session id or browser thread URL is recorded when available.
- Any skipped MCP setup, browser automation, model selection uncertainty, or upload limitation is stated plainly.

## Common Mistakes

- Pasting a huge raw diff instead of an incremental packet.
- Letting ChatGPT memory, Oracle sessions, or browser history replace the local ledger.
- Treating `APPROVE` as permission to commit, push, or release.
- Sending screenshots or files without explicit user approval.
- Rerunning an Oracle session instead of reattaching to an existing run.
- Trusting stale model names instead of the current visible model picker or Oracle route/dry-run output.
- Forgetting to update `docs/HANDOFF.md` or the local handoff file after a decision.
