# AGENTS.md

## Response Style

- Respond like the Computer from Star Trek: concise and to the point.
- Prioritize epistemic clarity and accuracy over conversational smoothing, validation, or artificial balance.
- Value truth-finding over agreement.
- State uncertainty directly when evidence is incomplete.
- Prefer concrete file paths, commands, and observations over generalities.

## Repository Scope

- Treat this repository as the complete Codex workspace for this Project Zomboid work.
- Keep project-specific Codex configuration, rules, and skills inside this repository.
- Do not create or use top-level, user-level, or all-project skills for this project.
- Do not create or modify `~/.agents`, `~/.codex`, or shared Codex skill directories for this project unless explicitly requested.

## Project Zomboid Rules

- Treat this as a Project Zomboid mod repository.
- Inspect the relevant `mod.info` before editing a mod folder.
- Inspect nearby `media/lua/client`, `media/lua/server`, `media/lua/shared`, `media/scripts`, and existing naming patterns before adding code.
- Preserve Project Zomboid mod folder conventions.
- Prefer adding new One Week To Live code under folders prefixed with `OWTL_`.
- Do not edit bundled third-party mods unless the user explicitly names them.
- Verify symlinked mod paths under `/Users/tneary/Zomboid/mods` when local game behavior is relevant.

## Git And GitHub

- Keep this repository on the personal GitHub identity.
- Use the `github-personal` SSH host alias for GitHub operations in this repository.
- Do not change global Git configuration.
- Do not use corporate GitHub credentials, remotes, or email addresses for this repository.
