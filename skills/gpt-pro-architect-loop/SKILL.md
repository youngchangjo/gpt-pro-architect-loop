---
name: gpt-pro-architect-loop
description: Use when the user wants ChatGPT Pro to act as an external architect, reviewer, or decision gate for Codex work across repo implementation rounds; optionally use Oracle as a transport helper when available.
version: 0.3.1
---

# GPT Pro Architect Loop

Use a dedicated external architect loop while Codex remains the builder with local repo access. The local repo is the canonical memory; the external model is an advisory reviewer fed by bounded, redacted packets.

Oracle is optional. Prefer it when it is installed because it handles file bundling, dry runs, sessions, follow-ups, and browser automation more reliably than manual ChatGPT.com operation. If Oracle is absent, blocked, or not approved for the current task, use the original browser path without treating that as a failure.

## Mental Model

Required core gate:

1. Build a focused packet.
2. Redact it.
3. Get approval before external transmission.
4. Send it through any approved transport.
5. Save the response.
6. Append the ledger.
7. Update durable continuity notes.

Optional transport choices:

- Oracle MCP.
- Oracle CLI.
- Oracle render/copy.
- Manual ChatGPT.com browser.

The transport can change only when needed. The local packet/response/ledger/continuity artifacts must not change.

## Transport Priority

Use the first available path that fits the user's approval scope. Skip Oracle when it is not installed, unavailable in the current Codex session, blocked by browser state, or outside the user's approval scope.

1. Oracle MCP `consult` when the `oracle` MCP server is available in the current Codex session.
2. Oracle CLI `oracle` when the CLI is installed but MCP is not available in this session.
3. Oracle render/copy mode when automation is blocked but a prepared bundle is still useful.
4. Manual ChatGPT.com browser thread as the final fallback.

Do not let a stronger transport weaken the safety rules. Oracle is a delivery layer, not the source of truth. Manual ChatGPT browser remains a valid path.

## Session Continuity Policy

Default to one external architect conversation per command, topic, and approval scope. Do not open a new ChatGPT conversation just because the packet number changed.

Start a new conversation only when one of these is true:

- The user asks for a fresh review.
- The topic, repo, destination, engine, or approval scope changes.
- The prior conversation is unrecoverable after checking Oracle sessions and the saved thread URL.
- The transport cannot technically continue the prior conversation, and the limitation is recorded in `thread.md` and `ledger.md`.

For same-topic work:

1. Read `.codex/gpt-pro-architect/thread.md` before each consult.
2. Reuse the active conversation URL, Oracle session, browser tab, or slug family when the transport supports it.
3. Prefer `browserFollowUps` or CLI `--browser-follow-up` for challenge/final-decision passes inside the same ChatGPT conversation.
4. Keep browser conversations unarchived until the topic is complete: use `browserArchive: "never"` and `browserKeepBrowser: true` in Oracle MCP, or the equivalent CLI flags.
5. If Oracle MCP cannot continue a completed ChatGPT conversation, switch to Oracle CLI `--followup`, `--browser-tab`, render/copy, or manual browser continuation instead of silently starting a new chat.
6. If a new session is unavoidable, keep the same `topic_id` and slug family, record the reason, and include the previous conversation URL in the next packet.

## Browser Reuse Policy

Prefer reusing an existing ChatGPT/Oracle Chrome surface over opening a fresh Chrome window. A new browser window is acceptable only when reuse is not available, not supported by the active transport, or would risk crossing topics/accounts/approval scopes.

Before a browser-based consult:

1. Read `.codex/gpt-pro-architect/thread.md` and look for:
   - `active conversation url`
   - `oracle latest session id`
   - `browser tab ref`
   - `slug family`
   - `continuation limitation`
2. Run `oracle status --hours 72 --limit 50` when Oracle CLI is available.
3. If a same-topic Oracle session or ChatGPT conversation exists, continue it with `--followup` or a saved browser tab instead of creating a new session.
4. Keep `--browser-keep-browser` and `--browser-archive never` for active topics so the browser surface remains reusable.
5. If Oracle dry-run or output says it will launch a visible Chrome window and an existing Oracle-controlled Chrome is already available, prefer one of these reuse paths before the live run:
   - `--followup <sessionId|responseId>` for same-topic continuation;
   - `--browser-tab <saved-tab-or-conversation-ref>` when a tab ref or conversation URL is known and the installed Oracle CLI accepts it;
   - `--browser-attach-running` to attach to an existing Oracle/Chrome browser when the installed Oracle CLI supports it;
   - `--remote-chrome <debug-endpoint>` only when the user intentionally provided a remote-debugging Chrome endpoint.
6. If MCP consult does not expose attach-running or tab-selection fields, use MCP for normal new consults but switch to Oracle CLI for same-topic browser reuse when the saved session/tab matters.
7. If none of the reuse paths works, record the limitation in `thread.md` and `ledger.md` before opening a new browser conversation.

Do not inspect Chrome cookies, local storage, profiles, passwords, or account internals while trying to reuse a browser. Reuse means targeting a known conversation/session surface, not reading browser state.

## Non-Negotiables

- Never send secrets, credentials, `.env` values, private keys, tokens, personal contact/payment identifiers, or unrelated user data.
- Treat every packet, upload, paste, screenshot, copied diff, Oracle bundle, Oracle MCP request, and ChatGPT.com browser action as external transmission.
- Get explicit user approval before the first transmission for a task. Ask again before sending new sensitive categories, uploads, screenshots, personal files, a different destination, or a different engine.
- Do not inspect Codex internal browser or Chrome cookies, local storage, passwords, session stores, or account internals.
- The architect cannot approve commits, pushes, releases, purchases, account changes, or permission changes by itself. `APPROVE` is an advisory gate; the user remains the authority.
- The local ledger and durable continuity notes are canonical memory. Do not rely on ChatGPT, Oracle sessions, or browser history as the source of truth.
- If Oracle session state conflicts with the local ledger, trust the local ledger and record the discrepancy before continuing.

## When Not To Use

- The user requested analysis-only and did not ask for an external architect/reviewer.
- The repo contains data that cannot be sent externally and cannot be safely summarized.
- The task can be handled with local tests, local review, or built-in Codex tools without an external architect.
- The user needs a guaranteed API-stable integration. ChatGPT.com and browser automation are best-effort.

## Setup

1. Find the repo root and read applicable `AGENTS.md` files.
2. Create `.codex/gpt-pro-architect/` for local state if it does not exist.
3. Use the repo's existing durable notes file when one already exists. Otherwise use `.codex/gpt-pro-architect/NOTES.md`. If a project already standardizes on a legacy `docs/HANDOFF.md` path, keep the path for compatibility but avoid exposing that wording in user-facing product copy.
4. Store external thread/session metadata in `.codex/gpt-pro-architect/thread.md`:

```md
# GPT Pro Architect Thread

- destination:
- transport: Oracle MCP | Oracle CLI | Oracle render/copy | ChatGPT browser
- model target: ChatGPT Pro / Pro Extended or Oracle preset
- topic id:
- status: active | complete | blocked | superseded
- slug family:
- active conversation url:
- previous conversation urls:
- oracle latest session id:
- oracle session ids:
- browser tab ref:
- created:
- updated:
- last packet:
- next packet:
- approval scope:
- archive policy: never while active, optional after complete
- reuse rule:
- continuation limitation:
- model evidence:
```

5. Optionally check local Oracle availability:

```bash
command -v oracle
oracle --version
oracle status --hours 24 --limit 20
```

6. If Oracle MCP is configured for Codex, prefer it. If it is not available in the current session, use the CLI or manual browser path and note that MCP may require a new Codex session after config changes.

## Oracle MCP Flow

Use this optional path only when the `oracle` MCP server is available as a callable tool in the current session.

1. Build the packet locally first; save it under `.codex/gpt-pro-architect/packets/packet-<N>.md`.
2. Run an MCP dry run before the real consult:

```json
{
  "preset": "chatgpt-pro-heavy",
  "engine": "browser",
  "prompt": "<Architect contract + decision question>",
  "files": [
    ".codex/gpt-pro-architect/packets/packet-<N>.md"
  ],
  "slug": "<topic-id>-packet-<N>",
  "browserArchive": "never",
  "browserKeepBrowser": true,
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

6. For same-topic revisions, first try to continue the active session or browser tab. If MCP cannot continue a completed conversation, switch to CLI `--followup`, `--browser-tab`, render/copy, or manual browser continuation.
7. If a long browser consult appears stalled, check Oracle sessions before retrying. Do not start duplicate runs until `oracle status` or MCP `sessions` shows the prior run is finished or unrecoverable.
8. Record the archive mode, keep-browser setting, conversation URL, session id, and any model-selection verification caveat in `thread.md` and `ledger.md`.

## Oracle CLI Flow

Use this optional path when Oracle is installed but MCP is not available in the current Codex session.

1. Save the packet first.
2. Preview the resolved bundle:

```bash
oracle \
  --engine browser \
  --model gpt-5.5-pro \
  --browser-model-strategy current \
  --browser-archive never \
  --browser-keep-browser \
  --browser-attachments auto \
  --files-report \
  --dry-run summary \
  --slug <topic-id>-packet-<N> \
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

6. If the next packet belongs to the same topic and Oracle can continue the browser session, prefer follow-up continuation and browser reuse. Keep the same Chrome/conversation surface when possible:

```bash
oracle \
  --followup <session-id-or-response-id> \
  --browser-archive never \
  --browser-keep-browser \
  --browser-follow-up "Challenge the prior decision. Keep the scope tight." \
  --browser-follow-up "Return the final APPROVE, REVISE, or BLOCK decision in the required format." \
  --prompt "Review the next packet in the same architect topic."
```

7. If a previous Oracle Chrome window is still open but `--followup` alone would launch a new one, try the installed CLI's browser reuse flags before sending the live packet:

```bash
oracle \
  --followup <session-id-or-response-id> \
  --browser-attach-running \
  --browser-archive never \
  --browser-keep-browser \
  --prompt "Review the next packet in the same architect topic."
```

If `--browser-attach-running` is unsupported by the installed Oracle version, remove it and record that limitation. If the user has provided a remote-debugging Chrome endpoint, use `--remote-chrome <debug-endpoint>` instead of launching a new Chrome.

8. Record Oracle session id, slug, model, engine, archive mode, keep-browser setting, conversation URL, browser tab/ref reuse attempt, and any browser automation limitation in `thread.md` and `ledger.md`.

## Manual Browser Fallback

Use this when Oracle is not installed, Oracle is blocked, Oracle is outside the current approval scope, or the user explicitly asks for the manual path. This is a first-class fallback, not a degraded review process.

1. Open the saved dedicated ChatGPT.com thread for the active topic first. Create a new thread only when the Session Continuity Policy allows it. If the saved thread cannot be opened, fall back to Chrome, then Computer Use.
2. In the current visible model picker, choose the best available Pro/Extended option. If no suitable Pro option is visible, stop and ask the user which model to use.
3. Pin the architect contract in the first message or re-send it when the thread has drifted.
4. Save the resulting thread URL in `.codex/gpt-pro-architect/thread.md` after every packet.
5. Before transmitting a packet, tell the user the destination and data categories, then request approval unless the current task already has explicit approval for those exact categories.

Do not automate login challenges, CAPTCHA, account security prompts, payment prompts, or permission changes. Pause for direct user action.

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
- Treat local ledger and continuity notes as canonical.
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
- data categories: repo summary, selected diffs, test output, continuity notes
- excluded: secrets, `.env`, credentials, unrelated personal data

## Canonical Memory
<Relevant excerpt from the repo's durable continuity notes or .codex/gpt-pro-architect/NOTES.md>

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
- When using Oracle, run `--dry-run summary` or MCP `dryRun: true` before live transmission when the file set changed.
- When using Oracle, use `--files-report` when attaching more than one packet or any source file.

## Preflight Before External Review

Before sending a packet, run a local preflight that can catch obvious review blockers without spending an external review round:

- Confirm `thread.md` points to the active topic, latest packet, next packet, and reuse rule.
- Confirm every referenced file path exists or is explicitly marked as future work.
- Search the packet and attached docs for unresolved placeholders such as `TODO`, `TBD`, `missing`, `placeholder`, and stale packet numbers.
- Check packet size with `wc -c`; keep the main packet under 12k-20k characters unless the user approved a larger bundle or file uploads.
- Check that approval scope, excluded data, and redaction notes are present.
- Check that implementation-plan packets include concrete file paths, interfaces, tests, and rollback boundaries rather than only prose.
- Check that image generation, asset generation, or visual QA requests are separated from the architect approval packet unless the architect is only reviewing the asset specification.

## Asset And Image Generation

Architect review and asset generation are separate workflows.

- Use the architect loop to approve prompts, acceptance criteria, and QA gates.
- Use a dedicated image-generation path for producing image files.
- Save generated asset paths and validation evidence outside the architect response file.
- If image generation fails or returns only text, record it as an asset-generation failure, not an architect-review failure.

## Ledger

After every architect exchange:

1. Save the outgoing packet as `.codex/gpt-pro-architect/packets/packet-<N>.md`.
2. Save the architect response as `.codex/gpt-pro-architect/responses/response-<N>.md`.
3. Append a short entry to `.codex/gpt-pro-architect/ledger.md`:

```md
## Round <N> - <date>
- sent:
- transport:
- topic id:
- conversation url:
- oracle session:
- archive policy:
- continuation:
- model evidence:
- architect decision:
- accepted actions:
- rejected actions:
- user decision:
- next:
```

4. Update the repo's durable continuity notes or `.codex/gpt-pro-architect/NOTES.md` with only durable decisions:
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
- `thread.md` reflects the active topic, conversation URL, latest session, and next packet.
- The latest architect decision is summarized.
- User approval scope is recorded.
- No known secrets or unrelated personal data were transmitted.
- Oracle session id or browser thread URL is recorded when available.
- Archive behavior, continuation behavior, skipped MCP setup, browser automation, model selection uncertainty, and upload limitation are stated plainly.

## Common Mistakes

- Pasting a huge raw diff instead of an incremental packet.
- Letting ChatGPT memory, Oracle sessions, or browser history replace the local ledger.
- Treating `APPROVE` as permission to commit, push, or release.
- Sending screenshots or files without explicit user approval.
- Starting a new ChatGPT conversation for the same topic instead of continuing or recording why continuation was impossible.
- Rerunning an Oracle session instead of reattaching to an existing run.
- Trusting stale model names instead of the current visible model picker or Oracle route/dry-run output.
- Treating asset generation failure as architect-review failure.
- Forgetting to update durable continuity notes after a decision.
