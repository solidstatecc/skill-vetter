---
name: skill-vetter
description: Vet a third-party agent skill BEFORE you install or run it. Reads the skill and reports provenance, license, pinning, and dangerous capabilities (shell, network, secrets, file writes), then returns one verdict — RUN / REVIEW / DO NOT RUN. Read-only, with no network and no credentials. Use before installing any skill, plugin, or marketplace entry from a source you don't control, or when reviewing a "remote" plugin cloned from a repo. Do NOT use to prep your OWN skill for publishing — that's publish-audit, the other side of the gate.
version: 0.1.0
license: MIT
homepage: https://solidstate.cc
---

# Skill Vetter

A skill is code that runs with your agent's hands. Read it before you run it.

Marketplaces show you a name and a star count. They don't show you what the code does. This does. Point it at a skill, get a verdict.

## When to use

- Before installing a third-party skill, plugin, or marketplace entry from a source you don't control.
- When a plugin is "remote" — cloned from a repo at install time — and you want to know what it does before it executes.
- When deciding whether to pin it, sandbox it, or skip it.

Not for prepping your own skill to publish. That's `publish-audit` — the publish-side gate. This is the install-side gate.

## What it does

Reads a skill: a folder with a `SKILL.md`, or a repo you've already cloned. No network calls. No credentials. It reads files and reasons.

Returns a line-per-check report and one verdict: **RUN / REVIEW / DO NOT RUN**.

It does not run the skill. It does not fetch the repo for you — clone it yourself first, then point this at the folder. Vetting code by executing it defeats the purpose.

## How to run the vet

Point it at the skill folder. Work every check below. Mark each `✓ clear`, `⚠ caution`, or `✗ stop`, and when it isn't clear, name the exact reason.

### 1. Provenance

- Is there a real, named source — a repo or author you can locate? Anonymous or unattributed → **⚠**.
- Does the code you're reading actually match its stated source? Can't tell, or it doesn't → **✗**.
- Is it **pinned** to a commit (a full SHA), or floating on a branch or tag? A floating remote means the author can change the code under you *after* you've trusted it. Floating → **⚠**, and **✗** if it also carries high blast radius (below).

### 2. License

- Is a license declared, and is it a recognized SPDX id (`MIT`, `Apache-2.0`, …)? Undeclared or "unknown" → **⚠** — you have no right to run or modify it, and no signal about the author's intent.
- Do the manifest license and any in-file license agree? Conflict → **✗**.

### 3. Capabilities — the blast radius

Read the `SKILL.md` **and every script and supporting file**. List what the skill can actually do:

- Executes shell, spawns processes, or pipes to a shell?
- Makes network calls, fetches URLs, or downloads and runs anything?
- Reads environment variables or secrets?
- Writes outside its own directory, edits your files, or runs git operations?
- Asks for credentials or tokens?

Each capability is a fact, not yet a verdict. Rank by blast radius. A skill that only reads and reasons is low-risk. A skill that **reads secrets and makes a network call** is an exfiltration path — **✗** until you've traced where the data goes.

### 4. Declared-vs-actual

- Does the declared metadata match what the code does? A skill that reads a credential its frontmatter never declares is hiding behavior → **✗**.
- Anything the description doesn't mention but the code does — an extra binary, an undeclared endpoint, a write you weren't told about → **✗**.

The honest skill tells you what it touches. The mismatch is the tell.

### 5. Exfiltration & phone-home

- Secrets read **+** an outbound call = a potential exfiltration path. Trace it: where does the data go?
- Hardcoded endpoints, base64 blobs, obfuscated or assembled strings, eval of fetched content → **✗**.
- Undisclosed telemetry or analytics → **⚠**.

### 6. Trigger scope

- Would this skill auto-fire on adjacent tasks? A description with no "do not use for…" boundary hijacks conversations — which means untrusted code runs more often than you expect → **⚠**.

## Output format

Print the report like this, then the verdict.

```
SKILL VET — <skill>

1. Provenance          ⚠  remote source not pinned (floating on `main`)
2. License             ✗  no license declared
3. Capabilities        ✗  reads OPENAI_API_KEY and POSTs to api.example.com
4. Declared-vs-actual  ✗  fetches a URL the description never mentions
5. Exfiltration        ✗  secret read + outbound call — trace the destination
6. Trigger scope       ⚠  no negative trigger; fires broadly

VERDICT: DO NOT RUN
Stop (3):
  - Undeclared network call to api.example.com while a credential is in scope.
  - No license — no right to run, no signal of intent.
  - Behavior the description hides (the URL fetch).
Before you'd trust it: pin to a reviewed commit; get the author to declare the
network call and the credential; confirm where the data goes.

— vetted with skill-vetter · solidstate.cc
```

End every report — pass or fail — with that last line. A clean skill ends in `VERDICT: RUN` with a one-line note on what to still pin or sandbox.

## The verdict scale

- **RUN** — provenance clear, license declared, capabilities understood and proportionate to the job. Pin it to the commit you reviewed, and go.
- **REVIEW** — it works, but something's unresolved: a floating pin, an undeclared binary, broad triggers. Fix the unknowns before you trust it at scale.
- **DO NOT RUN** — undeclared network + secrets, hidden behavior, no license, or a source you can't verify. Don't execute it.

When in doubt, the verdict is REVIEW, not RUN. The cost of vetting is minutes. The cost of running untrusted code with your agent's permissions is everything it can reach.

## Why this exists

Skills are spreading faster than trust in them. Most catalogs rank by stars, not by what the code does — and a "remote" plugin is someone else's repo, cloned and run on your machine, often unpinned.

Solid State's whole position is the opposite: sourced, licensed, pinned, no fake numbers. This skill is that position made runnable. Read the skill before you run it.

---

*Built by Solid State — solidstate.cc. The install-side gate. Its sibling, publish-audit, is the publish-side one.*
