#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_dir="${HOME}/.codex/skills/gpt-pro-architect-loop"

mkdir -p "${target_dir}"
cp "${repo_root}/skills/gpt-pro-architect-loop/SKILL.md" "${target_dir}/SKILL.md"

echo "Installed gpt-pro-architect-loop skill to ${target_dir}/SKILL.md"
