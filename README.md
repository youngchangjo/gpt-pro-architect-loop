# GPT Pro Architect Loop

Codex skill and operating guide for using ChatGPT Pro as an external architecture/review gate. The skill keeps Codex as the local builder, keeps repo-local evidence as the source of truth, and uses Oracle when available to reduce browser-operation friction.

## Current Status

- Skill version: `0.2.0`
- Oracle installed on this Mac: `0.15.0`
- Local source of truth: `skills/gpt-pro-architect-loop/SKILL.md`
- Installed Codex skill target: `~/.codex/skills/gpt-pro-architect-loop/SKILL.md`

## Why This Exists

The original flow used a dedicated ChatGPT.com Pro thread as a reviewer. That worked, but browser operation was slow and easy to lose track of:

- manual model selection
- manual packet paste/upload
- repeated browser state checks
- unclear session recovery
- a risk of treating a browser answer as canonical memory

The important part was never the browser itself. The important part was the gate:

- bounded architect packets
- explicit external-transmission approval
- redaction before sending
- `APPROVE`, `REVISE`, or `BLOCK`
- local packet/response/ledger artifacts
- durable decisions copied back to `docs/HANDOFF.md` or `.codex/gpt-pro-architect/HANDOFF.md`

Oracle improves the transport layer while the skill keeps the decision discipline.

## Transport Order

Use the first available path that fits the user's approval scope.

1. **Oracle MCP**: best path when the `oracle` MCP server is available in the current Codex session.
2. **Oracle CLI**: reliable fallback when the CLI is installed but MCP tools are not loaded.
3. **Oracle render/copy**: prepares the exact packet bundle for manual paste when automation is blocked.
4. **Manual ChatGPT browser**: final fallback for login challenges, tool drift, or operator preference.

Oracle is not the source of truth. The repo ledger is.

## Install

Oracle requires Node 24 or newer.

```bash
npm install -g @steipete/oracle
oracle --version
```

Install or update the Codex skill from this repo:

```bash
scripts/install.sh
```

## Codex MCP Setup

This machine uses Codex TOML MCP server entries. Add this to `~/.codex/config.toml` if it is not already present:

```toml
[mcp_servers.oracle]
command = "oracle-mcp"
args = []
startup_timeout_sec = 30

[mcp_servers.oracle.env]
ORACLE_ENGINE = "browser"
```

Restart Codex after changing MCP config. MCP tools are lazy-loaded by Codex, so an already-running session may still need the CLI fallback.

For clients that use `.mcp.json`, use:

```json
{
  "mcpServers": {
    "oracle": {
      "type": "stdio",
      "command": "oracle-mcp",
      "args": []
    }
  }
}
```

## First Browser Run

Oracle browser mode may need a one-time ChatGPT login profile. If a browser run fails because no signed-in session is available, run this manually and complete login in the opened browser:

```bash
oracle --engine browser --browser-manual-login \
  --browser-keep-browser --browser-input-timeout 120000 \
  --prompt "HI" --file README.md
```

After that, normal architect packet runs can use the saved automation profile.

## Packet Workflow

1. Create or update `.codex/gpt-pro-architect/packets/packet-<N>.md`.
2. Run an Oracle dry run before any live external transmission.
3. Confirm the destination and data categories match the user's approval scope.
4. Send through MCP or CLI.
5. Save the answer as `.codex/gpt-pro-architect/responses/response-<N>.md`.
6. Append `.codex/gpt-pro-architect/ledger.md`.
7. Update `docs/HANDOFF.md` or `.codex/gpt-pro-architect/HANDOFF.md` with durable decisions only.

## CLI Dry Run

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

Remove `--dry-run summary` only after approval is confirmed.

## MCP Consult Shape

When Codex exposes the Oracle MCP tools, start with `dryRun: true`:

```json
{
  "preset": "chatgpt-pro-heavy",
  "prompt": "Run the GPT Pro Architect review. Use the attached packet and required response format.",
  "files": [".codex/gpt-pro-architect/packets/packet-<N>.md"],
  "slug": "architect-packet-<N>",
  "dryRun": true
}
```

For ambiguous architecture decisions, add explicit follow-ups:

```json
{
  "browserFollowUps": [
    "Challenge your previous recommendation. Keep the scope tight.",
    "Return the final APPROVE, REVISE, or BLOCK decision in the required format."
  ]
}
```

## Existing Logic Preserved

The upgraded skill still keeps the original rules:

- do not send secrets
- ask before the first external transmission
- ask again for new sensitive categories, uploads, screenshots, personal files, new destination, or new engine
- keep ChatGPT/Oracle advisory only
- do not let `APPROVE` authorize commits, pushes, releases, purchases, account changes, or permission changes
- store packets, responses, ledger entries, and durable handoff notes locally
- keep approval scope narrow and stage-specific

## Versioning

Use SemVer for the skill:

- Patch: wording fixes, examples, safer defaults
- Minor: new transport, new ledger field, new workflow branch
- Major: changed approval semantics or changed artifact layout

Every release should update:

- `VERSION`
- `CHANGELOG.md`
- `skills/gpt-pro-architect-loop/SKILL.md` frontmatter

## References

- Oracle upstream: https://github.com/steipete/oracle
- Oracle MCP docs: https://askoracle.sh/mcp.html
- Oracle browser mode docs: https://askoracle.sh/browser-mode.html
