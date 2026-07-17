---
name: gpt-pro-architect-loop
description: Use when the user wants ChatGPT Pro to act as an external architect, reviewer, or decision gate for Codex work across repo implementation rounds; optionally use Oracle as a transport helper when available.
version: 0.5.1
---

# GPT Pro Architect Loop

Use a dedicated external architect loop while Codex remains the builder with local repo access. The local repo is the canonical memory; the external model is an advisory reviewer fed by bounded, redacted packets.

For the highest-capability browser review, target ChatGPT `Pro`, currently GPT-5.6 Sol Pro on eligible accounts. Keep that browser target distinct from the GPT-5.6 Sol API model.

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

Exception: when `thread.md` marks an active same-topic browser surface with `reuse required: true`, exact endpoint-plus-tab reuse outranks this transport order. Use CLI attach or manual continuation in the visible tab instead of an MCP path that cannot target that surface.

Do not let a stronger transport weaken the safety rules. Oracle is a delivery layer, not the source of truth. Manual ChatGPT browser remains a valid path.

## GPT-5.6 Target Policy

Keep the product label, Oracle alias, and API model id separate:

- Preferred architect target: ChatGPT browser `Pro`, requested from Oracle 0.16.0 or newer as `gpt-5-pro`. On eligible accounts, ChatGPT currently maps `Pro` to GPT-5.6 Sol Pro.
- Base Sol browser target: `gpt-5.6-sol` with `browserThinkingTime: "heavy"` or CLI `--browser-thinking-time heavy` for Extra High reasoning.
- API target: `gpt-5.6-sol`. API use is a different engine, may incur charges, and requires approval for that destination and engine.
- Do not use `gpt-5.6-sol-pro`; it is not an official API model id. GPT-5.6 Sol Pro is a ChatGPT picker target.
- Treat `chatgpt-pro-heavy` as a compatibility preset, not canonical GPT-5.6 model evidence. New GPT-5.6 MCP examples must use explicit `engine`, `model`, and model-selection fields.

Before the first GPT-5.6 consult in a session, verify Oracle support locally:

```bash
oracle --version
oracle --help --verbose | rg 'gpt-5\.6|gpt-5-pro'
```

Require Oracle 0.16.0 or newer before passing `gpt-5.6` or `gpt-5.6-sol`. Older Oracle builds can normalize those labels to an older model. Update Oracle or use the manual ChatGPT picker fallback instead of silently accepting the wrong target.

For model evidence, record all of the following when available:

- Oracle version.
- Requested Oracle alias.
- Dry-run resolved model.
- Live ChatGPT picker label and selection status.
- Any rollout, plan, workspace, or server-generation uncertainty.

A dry run proves routing only. A `Pro` picker label proves picker selection, but it does not independently prove the server-side model generation. Never perform a live verification by transmitting a packet without the required approval.

## Session Continuity Policy

Default to one external architect conversation per command, topic, and approval scope. Do not open a new ChatGPT conversation just because the packet number changed.

Start a new conversation only when one of these is true:

- The user asks for a fresh review.
- The topic, repo, destination, engine, or approval scope changes.
- The prior conversation is unrecoverable after checking Oracle sessions and the saved thread URL.
- The transport cannot technically continue the prior conversation, and the limitation is recorded in `thread.md` and `ledger.md`.

For an active same-topic loop, the last two conditions are blockers, not automatic permission to reset the browser. Obtain explicit user approval before opening a replacement window or conversation.

For same-topic work:

1. Read `.codex/gpt-pro-architect/thread.md` before each consult.
2. Reuse the same Chrome process and the exact active ChatGPT tab. Treat the saved conversation URL or target id plus the recorded CDP endpoint as the browser identity; a matching slug or Oracle session alone is insufficient.
3. Prefer `browserFollowUps` or CLI `--browser-follow-up` for challenge/final-decision passes inside the same ChatGPT conversation.
4. Keep browser conversations unarchived until the topic is complete. Use `browserKeepBrowser: true` or CLI `--browser-keep-browser` only for the command that launches and owns the persistent browser; never combine it with `--browser-attach-running`.
5. For a later packet, require a dry-run control plan that explicitly attaches to the recorded endpoint and reuses the recorded tab. If the plan would launch Chrome, open a dedicated tab, or cannot prove reuse, stop before the live run.
6. If Oracle MCP cannot target the exact existing tab, switch to the explicit CLI attach path or manually continue in the already-visible tab. Do not use a new MCP consult as a fallback.
7. Treat CLI `--followup` as conversation recovery only. It may restore a conversation URL from stored session configuration, but it does not prove reuse of the same Chrome process or tab.
8. If reuse fails, keep the same `topic_id` and slug family, record the failure, and ask the user before opening any new Chrome window or conversation.

## Browser Reuse Policy

For an active same-topic loop, browser reuse is fail-closed: do not open a fresh Chrome window or replacement ChatGPT tab unless the user explicitly approves that reset. The required invariant is one recorded Chrome debugging endpoint plus one exact ChatGPT conversation tab.

Before a browser-based consult:

1. Read `.codex/gpt-pro-architect/thread.md` and look for:
   - `active conversation url`
   - `browser endpoint`
   - `browser tab ref` (exact conversation URL or target id)
   - `browser owner`
   - `reuse required`
   - `new window allowed`
   - `last reuse preflight`
   - `slug family`
   - `continuation limitation`
2. Run `oracle status --hours 72 --limit 50` when Oracle CLI is available.
3. For the first packet with no reusable surface, launch exactly one persistent Oracle browser on a fixed port such as `9222` with `--browser-port 9222 --browser-keep-browser --browser-archive never`. After the live run, record the actual endpoint and exact active conversation URL or target id.
4. On a fresh Oracle-owned Chrome launch, require the unused `about:blank` bootstrap target to close as soon as the isolated run tab is attached. If it remains, update to the patched Oracle build before the next new-topic launch. Never sweep blank tabs when reusing, attaching to, or remotely controlling an existing browser.
5. For every later packet, use all of `--browser-attach-running`, `--remote-chrome <recorded-endpoint>`, and `--browser-tab <recorded-exact-url-or-target-id>`. Use `--browser-model-strategy current` and `--browser-archive never`; omit `--browser-keep-browser`, `--browser-port`, and `--followup` from the attach command.
6. Run that exact later-packet command with `--dry-run summary` first. Continue only when its control plan says it will attach to an already-running browser, reuse the matching ChatGPT tab, and leave the existing browser process alone.
7. Reject the live run if the dry run says it will launch Chrome, open a dedicated ChatGPT tab, cannot match the endpoint/tab, or otherwise lacks positive reuse evidence. Do not remove the attach flags to make the command succeed.
8. Prefer an exact conversation URL or target id over `--browser-tab current`. Use `current` only immediately after verifying that the endpoint's current tab is the recorded active conversation.
9. If MCP consult does not expose endpoint and tab selection, use MCP only for a first/new consult or follow-ups bundled into the same invocation. Switch to the CLI attach path for later same-topic packets.
10. If attach is unsupported or fails, record the limitation and manually continue in the already-visible tab, or pause for user direction. Opening a new window is not an automatic fallback.

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
- model target: GPT-5.6 Sol Pro via `gpt-5-pro` | GPT-5.6 Sol via `gpt-5.6-sol` | approved fallback
- topic id:
- status: active | complete | blocked | superseded
- slug family:
- active conversation url:
- previous conversation urls:
- oracle latest session id:
- oracle session ids:
- browser reuse mode: pinned-cdp | attached | manual
- browser endpoint: 127.0.0.1:9222
- browser owner: oracle-launched | attached | manual
- browser tab ref: exact conversation URL or target id
- reuse required: true
- new window allowed: false unless explicitly approved
- last reuse preflight:
- new windows opened this topic: 0
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
oracle --help --verbose | rg 'gpt-5\.6|gpt-5-pro'
oracle status --hours 24 --limit 20
rg -n 'closeOtherBlankTabs: !reusedChrome' \
  "$(npm root -g)/@steipete/oracle/dist/src/browser/index.js"
```

The final check identifies the fresh-launch blank-tab patch pinned on this Mac at `youngchangjo/oracle@d4175f3`. If it is missing, standard Oracle still works, but it can leave Chrome's bootstrap `about:blank` tab open.

6. If Oracle MCP is configured for Codex, prefer it for a new topic. When strict same-window reuse is active and MCP cannot target the recorded endpoint/tab, prefer CLI attach or manual continuation. If MCP is unavailable, use the CLI or manual browser path and note that MCP may require a new Codex session after config changes or a patched Oracle reinstall.

## Oracle MCP Flow

Use this optional path only when the `oracle` MCP server is available as a callable tool in the current session.

1. Build the packet locally first; save it under `.codex/gpt-pro-architect/packets/packet-<N>.md`.
2. Run an MCP dry run before the real consult:

```json
{
  "engine": "browser",
  "model": "gpt-5-pro",
  "browserModelStrategy": "select",
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
4. Use explicit `engine: "browser"`, `model: "gpt-5-pro"`, and `browserModelStrategy: "select"` for GPT-5.6 Sol Pro. If Pro is unavailable and the approved fallback is base Sol, use `model: "gpt-5.6-sol"` with `browserThinkingTime: "heavy"`.
5. For architecture decisions that benefit from a challenge pass, use `browserFollowUps` such as:

```json
[
  "Challenge your previous recommendation. Keep the scope tight.",
  "Return the final APPROVE, REVISE, or BLOCK decision in the required format."
]
```

6. For same-topic revisions inside one MCP invocation, use `browserFollowUps`. Across separate packets, if MCP cannot address the recorded endpoint and exact tab, switch to the CLI attach path or manually continue in the already-visible tab; do not start another MCP consult.
7. If a long browser consult appears stalled, check Oracle sessions before retrying. Do not start duplicate runs until `oracle status` or MCP `sessions` shows the prior run is finished or unrecoverable.
8. Record the archive mode, browser endpoint, exact tab ref, reuse preflight, conversation URL, session id, and any model-selection verification caveat in `thread.md` and `ledger.md`.

## Oracle CLI Flow

Use this path when Oracle is installed and MCP is unavailable, or whenever an active same-topic loop requires exact endpoint-plus-tab reuse that MCP cannot express.

1. Save the packet first.
2. For the first packet when no reusable browser is recorded, preview a single persistent browser launch on a fixed debugging port:

```bash
oracle \
  --engine browser \
  --model gpt-5-pro \
  --browser-model-strategy select \
  --browser-port 9222 \
  --browser-archive never \
  --browser-keep-browser \
  --browser-attachments auto \
  --files-report \
  --dry-run summary \
  --slug <topic-id>-packet-<N> \
  --prompt "Run the GPT Pro Architect review. Use the attached packet and required response format." \
  --file .codex/gpt-pro-architect/packets/packet-<N>.md
```

3. If the dry run is clean and the user has approved the destination/data categories, run it without `--dry-run`. Immediately record `127.0.0.1:9222` (or the chosen port) and the exact resulting ChatGPT conversation URL or target id in `thread.md`.
   - On a newly launched Oracle-owned browser, verify that the isolated ChatGPT work tab is the only page target and the launcher's unused `about:blank` tab has already closed.
4. For every later packet in the same topic, preview the exact attach command:

```bash
oracle \
  --engine browser \
  --model gpt-5-pro \
  --browser-attach-running \
  --remote-chrome 127.0.0.1:9222 \
  --browser-tab '<recorded-exact-conversation-url-or-target-id>' \
  --browser-model-strategy current \
  --browser-archive never \
  --browser-attachments auto \
  --files-report \
  --dry-run summary \
  --slug <topic-id>-packet-<N> \
  --prompt "Continue the same architect topic in this exact tab. Review packet <N>." \
  --file .codex/gpt-pro-architect/packets/packet-<N>.md
```

The dry-run control plan must positively state that Oracle will attach to the running browser and reuse the matching tab. It must not say that Oracle will launch Chrome or open a dedicated tab. Only then remove `--dry-run summary` for the approved live run. Attach failure is a stop condition, not permission to launch a replacement window.

5. Never combine `--browser-attach-running` with `--browser-keep-browser` or `--browser-port`; Oracle 0.16 rejects those combinations. Do not add `--followup` to the attach command: browser follow-up can restore stored conversation configuration without guaranteeing the same process/tab.
6. If the approved target is base GPT-5.6 Sol instead of Pro, replace `--model gpt-5-pro` with `--model gpt-5.6-sol --browser-thinking-time heavy`.
7. For challenge/final-decision passes known before a run, keep them in the same invocation and therefore the same tab:

```bash
oracle \
  --engine browser \
  --model gpt-5-pro \
  --browser-model-strategy select \
  --browser-port 9222 \
  --browser-archive never \
  --browser-keep-browser \
  --browser-follow-up "Challenge the prior decision. Keep the scope tight." \
  --browser-follow-up "Return the final APPROVE, REVISE, or BLOCK decision." \
  --prompt "Review the architect packet."
```

When attaching to an already-recorded browser, replace `--browser-model-strategy select --browser-port 9222 --browser-keep-browser` in this example with `--browser-attach-running --remote-chrome <recorded-endpoint> --browser-tab <recorded-exact-url-or-target-id> --browser-model-strategy current`.

8. For manual review or blocked browser automation, render and copy the exact bundle:

```bash
oracle \
  --render \
  --copy-markdown \
  --prompt "Run the GPT Pro Architect review. Use the attached packet and required response format." \
  --file .codex/gpt-pro-architect/packets/packet-<N>.md
```

9. If Oracle reports an existing matching/running session, inspect it instead of duplicating the run:

```bash
oracle status --hours 72 --limit 50
oracle session <session-id-or-slug> --render
```

10. Record Oracle session id, slug, requested alias, resolved picker label, engine, archive mode, browser endpoint, exact tab ref, reuse preflight result, conversation URL, and any browser automation limitation in `thread.md` and `ledger.md`.

## Manual Browser Fallback

Use this when Oracle is not installed, Oracle is blocked, Oracle is outside the current approval scope, or the user explicitly asks for the manual path. This is a first-class fallback, not a degraded review process.

1. Open the saved dedicated ChatGPT.com thread for the active topic first. Create a new thread only when the Session Continuity Policy allows it. If the saved thread cannot be opened, fall back to Chrome, then Computer Use.
2. In the current visible model picker, choose `Pro` for GPT-5.6 Sol Pro. If Pro is unavailable, use GPT-5.6 Sol at Extra High only when that fallback fits the approval scope; otherwise stop and ask the user which model to use.
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
- For a later same-topic browser packet, confirm the saved endpoint and exact tab ref exist and the dry-run control plan positively proves attach-and-reuse without a new Chrome launch or tab.
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
- browser endpoint:
- browser tab ref:
- reuse preflight:
- new window opened: no | yes with approval reference
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
- For same-topic browser work, the endpoint, exact tab ref, positive reuse preflight, and new-window count are recorded.
- A fresh Oracle-owned launch left no unused blank startup tab; reused or attached browser tabs were left untouched.
- Oracle version, requested alias, dry-run resolution, and live picker evidence are recorded when available.
- Archive behavior, continuation behavior, skipped MCP setup, browser automation, model selection uncertainty, and upload limitation are stated plainly.

## Common Mistakes

- Pasting a huge raw diff instead of an incremental packet.
- Letting ChatGPT memory, Oracle sessions, or browser history replace the local ledger.
- Treating `APPROVE` as permission to commit, push, or release.
- Sending screenshots or files without explicit user approval.
- Starting a new ChatGPT conversation for the same topic instead of continuing or recording why continuation was impossible.
- Rerunning an Oracle session instead of reattaching to an existing run.
- Combining `--browser-attach-running` with launch-only `--browser-keep-browser` or `--browser-port` flags.
- Assuming `--followup` alone guarantees reuse of the same Chrome process and tab.
- Using `--browser-tab current` when an exact saved conversation URL or target id is available.
- Removing attach flags after a reuse failure and silently allowing Oracle to launch a replacement window.
- Closing blank tabs in a reused or attached browser instead of limiting startup cleanup to a freshly launched Oracle-owned Chrome process.
- Trusting stale model names instead of the current visible model picker or Oracle route/dry-run output.
- Passing GPT-5.6 aliases to Oracle older than 0.16.0 and accepting an older resolved model.
- Inventing `gpt-5.6-sol-pro` instead of keeping ChatGPT Pro and the `gpt-5.6-sol` API id separate.
- Treating asset generation failure as architect-review failure.
- Forgetting to update durable continuity notes after a decision.
