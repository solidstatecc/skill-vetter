# skill-vetter

Vet a third-party agent skill **before** you install or run it.

A skill is packaged judgment — and packaged code that runs with your agent's hands. Most marketplaces show you a name and a star count, not what the code does. `skill-vetter` reads it first: provenance, license, pinning, and the real blast radius (shell, network, secrets, file writes). Then it returns one verdict: **RUN / REVIEW / DO NOT RUN**.

Read-only. No network. No credentials. It reads files and reasons.

- Skill: `skills/skill-vetter/SKILL.md`
- Command: `/vet <path-or-repo>`

It's the install-side gate. Its sibling, `publish-audit`, is the publish-side gate.

Built by [Solid State](https://solidstate.cc). Sourced, licensed, pinned. Read the skill before you run it.

MIT.
